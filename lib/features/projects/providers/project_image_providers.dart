import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/project_image.dart';
import '../repositories/project_image_repository.dart';
import '../repositories/project_repository.dart';
import 'project_providers.dart';

final projectImagesProvider = FutureProvider.family<List<ProjectImage>, String>((ref, projectId) async {
  final repository = ref.read(projectImageRepositoryProvider);
  final response = await repository.fetchImages(projectId);
  return response.data;
});

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
      throw Exception('Location services are disabled. Enable GPS to attach photo metadata.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Unable to upload image without location.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable in Settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
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

  Future<void> uploadThumbnail({
    required String projectId,
    required String filePath,
  }) async {
    state = const AsyncLoading();
    try {
      await _projectRepository.uploadProjectThumbnail(projectId, filePath);
      state = const AsyncData(null);
      ref.invalidate(projectDetailsProvider(projectId));
      ref.invalidate(projectsListProvider);
    } catch (e, st) {
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
      await _projectRepository.deleteProjectThumbnail(projectId, coverImageId);
      state = const AsyncData(null);
      ref.invalidate(projectDetailsProvider(projectId));
      ref.invalidate(projectsListProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final projectImageNotifierProvider = AsyncNotifierProvider<ProjectImageNotifier, void>(ProjectImageNotifier.new);
