import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../models/contractor_register_request.dart';
import '../models/product_owner_register_request.dart';
import '../repositories/auth_repository.dart';
import '../../../core/auth/session_manager.dart';
import '../../../core/api/api_client.dart';
import '../../notifications/services/notification_lifecycle_service.dart';
import '../../../core/api/pusher_service.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  String? _hydratedToken;
  Future<void>? _backgroundRefresh;

  @override
  Future<AuthResponse?> build() async {
    ref.watch(sessionRefreshProvider);

    final sessionManager = ref.read(sessionManagerProvider);
    final token = await sessionManager.getToken();
    final user = await sessionManager.getUser();

    if (token == null || token.isEmpty) {
      _hydratedToken = null;
      return null;
    }

    if (user != null && user.isNotEmpty) {
      final response = AuthResponse.fromSession(token: token, user: user);
      if (!_hasSupportedRole(response)) {
        await sessionManager.clearSession();
        return null;
      }

      _refreshCurrentUserInBackground(token: token, cachedUser: user);
      return response;
    }

    return _hydrateSession(token: token, cachedUser: user);
  }

  Future<void> registerContractor(ContractorRegisterRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerContractor(request);
      return persistAuthenticatedResponse(response);
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(email, password);
      return persistAuthenticatedResponse(response);
    });
  }

  Future<void> registerOwner(ProductOwnerRegisterRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerOwner(request);
      return persistAuthenticatedResponse(response);
    });
  }

  Future<void> logout() async {
    final notificationLifecycle = ref.read(notificationLifecycleProvider);
    final repository = ref.read(authRepositoryProvider);
    final sessionManager = ref.read(sessionManagerProvider);
    final pusherService = ref.read(pusherServiceProvider);

    // 1. Capture token for the final API call before we wipe it locally
    final token = await sessionManager.getToken();
    
    // 2. Unregister tokens and fire API logout (fire-and-forget)
    unawaited(notificationLifecycle.unregisterCurrentDeviceToken());
    
    // Fire the logout request using the captured token.
    unawaited(repository.logout(token: token).catchError((_) {
      return AuthResponse(status: false, message: 'Logout failed');
    }));

    // 3. Clear local session immediately for instant UX
    await sessionManager.clearSession();
    await notificationLifecycle.handleLoggedOut();
    pusherService.disconnect();
    
    state = const AsyncValue.data(null);
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.forgotPassword(email);
    });
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    });
  }

  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.acceptInvitation(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    });
  }

  Future<void> updateCurrentUser(Map<String, dynamic> newUser) async {
    final current = state.asData?.value;
    final sessionManager = ref.read(sessionManagerProvider);
    final token = current?.data?.token ?? await sessionManager.getToken();

    if (token == null || token.isEmpty) {
      return;
    }

    // 1. Get existing user data to ensure we don't lose anything (especially roles)
    final existingUser =
        current?.data?.user ?? await sessionManager.getUser() ?? {};

    // 2. Perform a role-preserving merge
    final mergedUser = {
      ...existingUser,
      ...newUser,
    };

    // If the new user object is missing the role but we had it before, keep the old one.
    // This prevents accidental logouts when an API returns a partial profile.
    if ((newUser['role'] == null || newUser['role'].toString().isEmpty) &&
        existingUser['role'] != null) {
      mergedUser['role'] = existingUser['role'];
    }

    final response = AuthResponse.fromSession(
      token: token,
      user: mergedUser,
      message: 'Profile updated',
    );

    // 3. Validation - only clear if the role is confirmed invalid, not just missing
    if (!_hasSupportedRole(response)) {
      debugPrint('[AUTH] updateCurrentUser failed: Role is unknown.');
      // If we HAD a role and now it's gone, that's a problem. 
      // But if we're just in the middle of a partial update, don't wipe.
      if (mergedUser['role'] == null || mergedUser['role'].toString().isEmpty) {
         // Potential false positive? Let's be safe and NOT logout here 
         // unless we are sure the user is invalid.
         return;
      }
      
      await sessionManager.clearSession();
      state = const AsyncValue.data(null);
      return;
    }

    await sessionManager.saveUser(mergedUser);
    state = AsyncValue.data(response);
  }

  Future<void> markEmailVerified({String? verifiedAt}) async {
    final currentUser = state.asData?.value?.data?.user;
    if (currentUser == null || currentUser.isEmpty) {
      return;
    }

    final updatedUser = <String, dynamic>{
      ...currentUser,
      'email_verified_at':
          verifiedAt ?? DateTime.now().toUtc().toIso8601String(),
    };
    await updateCurrentUser(updatedUser);
  }

  Future<AuthResponse?> _hydrateSession({
    required String token,
    Map<String, dynamic>? cachedUser,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final sessionManager = ref.read(sessionManagerProvider);

    try {
      final user = await repository.fetchCurrentUser(cachedUser: cachedUser);
      final response = AuthResponse.fromSession(token: token, user: user);
      if (!_hasSupportedRole(response)) {
        await sessionManager.clearSession();
        return null;
      }

      await sessionManager.saveSession(token, user);
      return response;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await sessionManager.clearSession();
        return null;
      }
      rethrow;
    }
  }

  void _refreshCurrentUserInBackground({
    required String token,
    Map<String, dynamic>? cachedUser,
  }) {
    if (_hydratedToken == token) {
      return;
    }

    _hydratedToken = token;
    _backgroundRefresh =
        _refreshCurrentUser(token: token, cachedUser: cachedUser).whenComplete(
          () {
            _backgroundRefresh = null;
          },
        );
    unawaited(_backgroundRefresh);
  }

  Future<void> _refreshCurrentUser({
    required String token,
    Map<String, dynamic>? cachedUser,
  }) async {
    try {
      final hydrated = await _hydrateSession(
        token: token,
        cachedUser: cachedUser,
      );
      if (!ref.mounted) {
        return;
      }

      final activeToken = await ref.read(sessionManagerProvider).getToken();
      if (activeToken != token) {
        return;
      }

      state = AsyncValue.data(hydrated);
    } catch (_) {
      // Keep the cached user on screen when a background refresh fails.
    }
  }

  Future<AuthResponse> persistAuthenticatedResponse(
    AuthResponse response,
  ) async {
    if (!response.isAuthenticated) {
      state = AsyncValue.data(response);
      return response;
    }

    if (!_hasSupportedRole(response)) {
      await ref.read(sessionManagerProvider).clearSession();
      state = const AsyncValue.data(null);
      throw Exception('Your account does not have a supported role.');
    }

    await ref
        .read(sessionManagerProvider)
        .saveSession(response.data!.token, response.data!.user);
    state = AsyncValue.data(response);
    return response;
  }


  bool _hasSupportedRole(AuthResponse response) {
    return response.role != UserRole.unknown;
  }
}

/// A simple notifier that helps the router refresh when welcome status changes.
/// This acts as a global 'dirty' flag for the welcome state.
class WelcomeSeenRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final welcomeSeenRefreshProvider =
    NotifierProvider<WelcomeSeenRefreshNotifier, int>(
  WelcomeSeenRefreshNotifier.new,
);

/// Tracks whether a given user has already seen the welcome screen.
final welcomeSeenProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  // Watch the refresh provider so we can manually trigger a re-fetch
  ref.watch(welcomeSeenRefreshProvider);
  final sessionManager = ref.read(sessionManagerProvider);
  return sessionManager.hasSeenWelcome(userId);
});

/// A service to handle the welcome seen logic reactively.
final welcomeSeenActionProvider = Provider((ref) => WelcomeSeenAction(ref));

class WelcomeSeenAction {
  final Ref _ref;
  WelcomeSeenAction(this._ref);

  Future<void> markAsSeen(String userId) async {
    final sessionManager = _ref.read(sessionManagerProvider);
    await sessionManager.setWelcomeSeen(userId);
    // Trigger all listeners to re-fetch
    _ref.read(welcomeSeenRefreshProvider.notifier).increment();
  }
}
