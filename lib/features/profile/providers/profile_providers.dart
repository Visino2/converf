import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_models.dart';
import '../repositories/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/auth/session_manager.dart';

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return await repository.fetchProfile();
});

final notificationSettingsProvider = FutureProvider<NotificationSettings>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return await repository.fetchNotificationSettings();
});

class ProfileNotifier extends AsyncNotifier<void> {
  late ProfileRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(profileRepositoryProvider);
  }

  Future<bool> updateProfile(UpdateProfilePayload payload) async {
    state = const AsyncLoading();
    try {
      final updatedProfile = await _repository.updateProfile(payload);
      
      // Update local session safely via AuthNotifier
      final sessionManager = ref.read(sessionManagerProvider);
      final currentToken = await sessionManager.getToken();
      final currentUser = await sessionManager.getUser();

      if (currentToken != null && currentUser != null) {
        // Use the auth notifier to update state cleanly with role-preservation
        await ref.read(authProvider.notifier).updateCurrentUser(updatedProfile.toJson());
      }
      
      // Refresh supplemental providers
      ref.invalidate(profileProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateProfilePicture(String filePath) async {
    state = const AsyncLoading();
    try {
      final updatedProfile = await _repository.updateProfilePicture(filePath);
      
      // Update local session safely via AuthNotifier
      final sessionManager = ref.read(sessionManagerProvider);
      final currentToken = await sessionManager.getToken();
      final currentUser = await sessionManager.getUser();

      if (currentToken != null && currentUser != null) {
        // Use the auth notifier to update state cleanly with role-preservation
        await ref.read(authProvider.notifier).updateCurrentUser(updatedProfile.toJson());
      }
      
      // Refresh supplemental providers
      ref.invalidate(profileProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    state = const AsyncLoading();
    try {
      await _repository.updateNotificationSettings(settings);
      ref.invalidate(notificationSettingsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> changePassword(ChangePasswordPayload payload) async {
    state = const AsyncLoading();
    try {
      await _repository.changePassword(payload);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, void>(ProfileNotifier.new);
