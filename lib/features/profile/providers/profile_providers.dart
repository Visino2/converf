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

  Future<void> updateProfile(UpdateProfilePayload payload) async {
    state = const AsyncLoading();
    try {
      final updatedProfile = await _repository.updateProfile(payload);
      
      // Update local session
      final sessionManager = ref.read(sessionManagerProvider);
      final currentToken = await sessionManager.getToken();
      if (currentToken != null) {
         await sessionManager.saveSession(currentToken, updatedProfile.toJson());
      }
      
      // Refresh providers
      ref.invalidate(profileProvider);
      // Also potentially invalidate authProvider if it depends on the user object
      ref.invalidate(authProvider);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateProfilePicture(String filePath) async {
    state = const AsyncLoading();
    try {
      final updatedProfile = await _repository.updateProfilePicture(filePath);
      
      // Update local session
      final sessionManager = ref.read(sessionManagerProvider);
      final currentToken = await sessionManager.getToken();
      if (currentToken != null) {
         await sessionManager.saveSession(currentToken, updatedProfile.toJson());
      }
      
      // Refresh providers
      ref.invalidate(profileProvider);
      ref.invalidate(authProvider);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
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
