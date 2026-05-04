import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../models/contractor_register_request.dart';
import '../models/product_owner_register_request.dart';
import '../repositories/auth_repository.dart';
import '../services/biometric_auth_service.dart';
import '../../../core/auth/session_manager.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/shared_prefs_provider.dart';
import '../../notifications/services/notification_lifecycle_service.dart';

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
        await sessionManager.clearSession(notifySessionChange: false);
        return null;
      }

      _refreshCurrentUserInBackground(token: token, cachedUser: user);
      return response;
    }

    return _hydrateSession(token: token, cachedUser: user);
  }

  Future<void> registerContractor(ContractorRegisterRequest request) async {
    debugPrint('[AUTH] Contractor signup attempt for: ${request.email}');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('[AUTH] Getting repository...');
        final repository = ref.read(authRepositoryProvider);
        debugPrint('[AUTH] Calling repository.registerContractor()...');
        final response = await repository.registerContractor(request);
        debugPrint(
          '[AUTH] Signup response: status=${response.status}, message=${response.message}',
        );
        // Force email_verified_at to null so the router always redirects to
        // verification after signup (mirrors web app goToVerification behaviour).
        final safeResponse = _withUnverifiedEmail(response);
        final authData = await persistAuthenticatedResponse(safeResponse);
        debugPrint('[AUTH] Contractor signup successful, token persisted');
        return authData;
      } catch (e, stack) {
        debugPrint('[AUTH ERROR] Contractor signup failed: $e');
        debugPrint('[STACK] $stack');
        rethrow;
      }
    });
  }

  /// Returns a copy of [response] with email_verified_at set to null.
  AuthResponse _withUnverifiedEmail(AuthResponse response) {
    if (response.data == null) return response;
    final user = Map<String, dynamic>.from(response.data!.user)
      ..['email_verified_at'] = null;
    return AuthResponse.fromSession(
      token: response.data!.token,
      user: user,
      message: response.message,
    );
  }

  Future<void> login(String email, String password) async {
    debugPrint('[AUTH] Login attempt for: $email');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('[AUTH] Getting repository...');
        final repository = ref.read(authRepositoryProvider);
        debugPrint('[AUTH] Calling repository.login()...');
        final response = await repository.login(email, password);
        debugPrint(
          '[AUTH] Login response: status=${response.status}, message=${response.message}',
        );
        final authData = await persistAuthenticatedResponse(response);
        debugPrint('[AUTH] Login successful, token persisted');
        return authData;
      } catch (e, stack) {
        debugPrint('[AUTH ERROR] Login failed: $e');
        debugPrint('[STACK] $stack');
        rethrow;
      }
    });
  }

  Future<void> registerOwner(ProductOwnerRegisterRequest request) async {
    debugPrint('[AUTH] Owner signup attempt for: ${request.email}');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(authRepositoryProvider);
        final response = await repository.registerOwner(request);
        debugPrint('[AUTH] Signup response: status=${response.status}');
        final authData = await persistAuthenticatedResponse(response);
        // Flag this as a new signup so the dashboard shows the welcome popup
        final userId = authData.data?.user['id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          await ref.read(sessionManagerProvider).setNewSignup(userId);
        }
        debugPrint('[AUTH] Owner signup successful, token persisted');
        return authData;
      } catch (e, stack) {
        debugPrint('[AUTH ERROR] Owner signup failed: $e');
        debugPrint('[STACK] $stack');
        rethrow;
      }
    });
  }

  Future<bool> loginWithBiometric() async {
    debugPrint('[AUTH] ========== BIOMETRIC LOGIN START ==========');
    final biometricService = ref.read(biometricAuthServiceProvider);
    final repository = ref.read(authRepositoryProvider);

    final deviceToken = biometricService.getDeviceToken();
    if (deviceToken == null || deviceToken.isEmpty) return false;

    try {
      // Exchange the long-lived biometric device token for a fresh session token.
      final response = await repository.loginWithBiometricToken(deviceToken);
      if (!response.isAuthenticated) {
        await biometricService.disable();
        return false;
      }
      final authData = await persistAuthenticatedResponse(response);
      debugPrint('[AUTH] Biometric login successful');
      return authData.isAuthenticated;
    } on ApiException catch (e) {
      debugPrint('[AUTH] Biometric login failed (${e.statusCode}): ${e.message}');
      if (e.statusCode == 401 || e.statusCode == 403) {
        await biometricService.disable();
      }
      return false;
    } catch (e) {
      debugPrint('[AUTH] Biometric login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    debugPrint('[AUTH] Logout initiated');
    final notificationLifecycle = ref.read(notificationLifecycleProvider);
    final repository = ref.read(authRepositoryProvider);
    final sessionManager = ref.read(sessionManagerProvider);

    debugPrint('[AUTH] Updating state to null (trigger redirect)...');
    // 1. Update state immediately to trigger AppRouter redirect
    state = const AsyncValue.data(null);

    // 2. Capture token for the final API call before we wipe it locally
    debugPrint('[AUTH] Capturing token...');
    final token = await sessionManager.getToken();
    debugPrint('[AUTH] Token captured: ${token != null ? '****' : 'null'}');

    // 3. Stop app-side realtime work immediately so logout does not race with
    // active listeners/pollers while the router redirects.
    await notificationLifecycle.handleLoggedOut();

    // 4. Finish server-side cleanup in the background using the captured token.
    if (token != null && token.isNotEmpty) {
      unawaited(() async {
        debugPrint('[AUTH] Unregistering device token...');
        try {
          await notificationLifecycle.unregisterCurrentDeviceToken(
            authToken: token,
          );
        } catch (e) {
          debugPrint('[AUTH] Device token cleanup failed: $e');
        }

        debugPrint('[AUTH] Calling repository.logout()...');
        try {
          await repository.logout(token: token);
          debugPrint('[AUTH] Logout API call successful');
        } catch (e) {
          debugPrint('[AUTH] Logout API call failed: $e');
        }
      }());
    } else {
      debugPrint('[AUTH] No token available for server-side logout cleanup.');
    }

    // 5. Clear local session immediately for instant UX
    debugPrint('[AUTH] Clearing local session...');
    await sessionManager.clearSession(notifySessionChange: false);
    debugPrint('[AUTH] Session cleared');
    debugPrint('[AUTH] Logout complete');
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
    final mergedUser = {...existingUser, ...newUser};

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

      await sessionManager.clearSession(notifySessionChange: false);
      state = const AsyncValue.data(null);
      return;
    }

    await sessionManager.saveUser(mergedUser, notifySessionChange: false);
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
        await sessionManager.clearSession(notifySessionChange: false);
        return null;
      }

      await sessionManager.saveSession(token, user, notifySessionChange: false);
      return response;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await sessionManager.clearSession(notifySessionChange: false);
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

  Future<void> refreshUser() async {
    final token = await ref.read(sessionManagerProvider).getToken();
    if (token == null || token.isEmpty) return;
    await _refreshCurrentUser(token: token);
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
      await ref
          .read(sessionManagerProvider)
          .clearSession(notifySessionChange: false);
      state = const AsyncValue.data(null);
      throw Exception('Your account does not have a supported role.');
    }

    final token = response.data!.token;
    final user = response.data!.user;

    await ref
        .read(sessionManagerProvider)
        .saveSession(token, user, notifySessionChange: false);

    // Persist email so the login form can prefill it even after logout.
    final email = user['email'] as String?;
    if (email != null && email.isNotEmpty) {
      unawaited(
        ref.read(sharedPreferencesProvider).setString('last_login_email', email),
      );
    }

    // Auto-mark welcome as seen immediately after login to skip welcome screen
    // This provides smooth navigation: Login → Dashboard (no intermediate screens)
    final userId = response.data?.user['id']?.toString() ?? '';
    if (userId.isNotEmpty) {
      try {
        await ref.read(welcomeSeenActionProvider).markAsSeen(userId);
        debugPrint('[AUTH] Welcome marked as seen for user: $userId');
      } catch (e) {
        debugPrint('[AUTH] Warning: Could not mark welcome as seen: $e');
        // Continue anyway - this is non-critical
      }
    }

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
/// Synchronous read — _prefs.getBool is already in-memory, no async needed.
/// This avoids an isLoading flash that would leave the router stuck on the
/// login route after sign-in (nobody re-triggers the router when the Future
/// resolves, so isLoading → null redirect → user stuck on login).
final welcomeSeenProvider = Provider.family<bool, String>((ref, userId) {
  ref.watch(welcomeSeenRefreshProvider);
  final sessionManager = ref.read(sessionManagerProvider);
  return sessionManager.hasSeenWelcomeSync(userId);
});

/// A service to handle the welcome seen logic reactively.
final welcomeSeenActionProvider = Provider((ref) => WelcomeSeenAction(ref));

class WelcomeSeenAction {
  final Ref _ref;
  WelcomeSeenAction(this._ref);

  Future<void> markAsSeen(String userId) async {
    final sessionManager = _ref.read(sessionManagerProvider);
    await sessionManager.setWelcomeSeen(userId, notifySessionChange: false);
    // Trigger all listeners to re-fetch
    _ref.read(welcomeSeenRefreshProvider.notifier).increment();
  }
}
