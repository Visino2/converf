import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/project_image.dart';
import '../repositories/project_image_repository.dart';
import '../repositories/project_repository.dart';
import 'project_providers.dart';
import '../../../core/providers/cache_provider.dart';

final projectImagesProvider = FutureProvider.family<List<ProjectImage>, String>(
  (ref, projectId) async {
    try {
      final repository = ref.read(projectImageRepositoryProvider);
      final response = await repository.fetchImages(projectId);
      return response.data;
    } catch (e) {
      debugPrint('[ProjectImages] Error fetching images: $e');
      // Return empty list on auth/network errors to allow UI to recover
      return [];
    }
  },
);

/// Cover images (thumbnails) derived from the project detail response.
/// Uses [projectDetailsProvider] so invalidating project details automatically
/// refreshes cover images without hitting the GPS-images endpoint.
final projectCoverImagesProvider = FutureProvider.family<List<ProjectImage>, String>(
  (ref, projectId) async {
    try {
      final response = await ref.watch(projectDetailsProvider(projectId).future);
      return response.data?.coverImages ?? [];
    } catch (e) {
      debugPrint('[ProjectCoverImages] Error fetching cover images: $e');
      return [];
    }
  },
);

class ProjectImageNotifier extends AsyncNotifier<void> {
  late ProjectImageRepository _repository;
  late ProjectRepository _projectRepository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(projectImageRepositoryProvider);
    _projectRepository = ref.read(projectRepositoryProvider);
  }

  Future<void> uploadImage({
    required String projectId,
    required String filePath,
    String? caption,
    bool isPrimary = false,
  }) async {
    state = const AsyncLoading();
    try {
      final position = await _getPosition();
      final capturedAt = DateTime.now();

      await _repository.uploadImage(
        projectId: projectId,
        filePath: filePath,
        caption: caption,
        isPrimary: isPrimary,
        capturedLatitude: position.latitude,
        capturedLongitude: position.longitude,
        capturedAccuracyM: position.accuracy,
        capturedAt: capturedAt,
      );
      state = const AsyncData(null);
      ref.invalidate(projectImagesProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Enable GPS to attach photo metadata.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied. Unable to upload image without location.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Please enable in Settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  Future<void> deleteImage(String projectId, String imageId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteImage(projectId, imageId);
      state = const AsyncData(null);
      ref.invalidate(projectImagesProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<List<ProjectImage>> uploadThumbnail({
    required String projectId,
    required String filePath,
  }) async {
    state = const AsyncLoading();
    try {
      final cacheService = ref.read(hiveCacheServiceProvider);
      final result = await _projectRepository.uploadProjectThumbnail(
        projectId,
        filePath,
      );
      state = const AsyncData(null);

      // Cache each thumbnail image
      final coverImages = result.data?.coverImages ?? [];
      for (final image in coverImages) {
        await cacheService.cacheThumbnail(projectId, image.id, {
          'id': image.id,
          'projectId': image.projectId,
          'fileUrl': image.fileUrl,
          'fileSize': image.fileSize,
          'mimeType': image.mimeType,
          'caption': image.caption,
          'isPrimary': image.isPrimary,
          'createdAt': image.createdAt.toIso8601String(),
          'updatedAt': image.updatedAt.toIso8601String(),
        });
      }

      // Add to sync queue for offline sync
      await cacheService.addToSyncQueue(
        projectId,
        'thumbnail',
        DateTime.now().millisecondsSinceEpoch.toString(),
        {'filePath': filePath, 'uploadedAt': DateTime.now().toIso8601String()},
      );

      // Invalidate project details so cover images are re-fetched from server
      ref.invalidate(projectDetailsProvider(projectId));

      // Return the cover images from the upload response directly
      return coverImages;
    } catch (e, st) {
      debugPrint('[ProjectImageNotifier] Thumbnail upload error: $e');
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteThumbnail({
    required String projectId,
    required String coverImageId,
  }) async {
    state = const AsyncLoading();
    try {
      debugPrint(
        '[ProjectImageNotifier] Deleting thumbnail $coverImageId for project $projectId',
      );
      await _projectRepository.deleteProjectThumbnail(projectId, coverImageId);
      state = const AsyncData(null);
      // Invalidate project details so cover images are re-fetched from server
      ref.invalidate(projectDetailsProvider(projectId));
      ref.invalidate(assignedProjectsProvider(1));
      ref.invalidate(projectsListProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteAllImages(String projectId, List<String> imageIds) async {
    state = const AsyncLoading();
    try {
      for (final id in imageIds) {
        // We use the same image deletion endpoint for both thumbnails and regular images
        // as they share the same resource ID and backend tracker.
        await _projectRepository.deleteProjectThumbnail(projectId, id);
      }
      state = const AsyncData(null);
      ref.invalidate(projectImagesProvider(projectId));
      ref.invalidate(projectDetailsProvider(projectId));
      ref.invalidate(assignedProjectsProvider(1));
      ref.invalidate(projectsListProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final projectImageNotifierProvider =
    AsyncNotifierProvider<ProjectImageNotifier, void>(ProjectImageNotifier.new);
