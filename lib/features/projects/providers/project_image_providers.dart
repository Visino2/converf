import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_image.dart';
import '../repositories/project_image_repository.dart';

final projectImagesProvider = FutureProvider.family<List<ProjectImage>, String>((ref, projectId) async {
  final repository = ref.read(projectImageRepositoryProvider);
  final response = await repository.fetchImages(projectId);
  return response.data;
});

class ProjectImageNotifier extends AsyncNotifier<void> {
  late ProjectImageRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(projectImageRepositoryProvider);
  }

  Future<void> uploadImage({
    required String projectId,
    required String filePath,
    String? caption,
    bool isPrimary = false,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.uploadImage(
        projectId: projectId,
        filePath: filePath,
        caption: caption,
        isPrimary: isPrimary,
      );
      state = const AsyncData(null);
      ref.invalidate(projectImagesProvider(projectId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
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
}

final projectImageNotifierProvider = AsyncNotifierProvider<ProjectImageNotifier, void>(ProjectImageNotifier.new);
