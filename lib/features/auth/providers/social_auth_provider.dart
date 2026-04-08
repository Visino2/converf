import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response.dart';
import '../models/social_auth_method.dart';
import '../repositories/auth_repository.dart';
import 'auth_provider.dart';
import 'email_verification_provider.dart';

import '../../../core/config/shared_prefs_provider.dart';

final pendingSocialAuthStoreProvider = Provider<PendingSocialAuthStore>((ref) {
  return PendingSocialAuthStore(ref.read(sharedPreferencesProvider));
});

final socialAuthActionProvider =
    AsyncNotifierProvider<SocialAuthNotifier, void>(SocialAuthNotifier.new);

class PendingSocialAuth {
  const PendingSocialAuth({required this.method, required this.role});

  final SocialAuthMethod method;
  final UserRole role;
}

class PendingSocialAuthStore {
  final SharedPreferences _prefs;

  PendingSocialAuthStore(this._prefs);

  static const _methodKey = 'pending_social_auth_method';
  static const _roleKey = 'pending_social_auth_role';

  Future<void> save({
    required SocialAuthMethod method,
    required UserRole role,
  }) async {
    await _prefs.setString(_methodKey, method.name);
    await _prefs.setString(_roleKey, role.name);
  }

  Future<PendingSocialAuth?> read() async {
    final methodName = _prefs.getString(_methodKey);
    final roleName = _prefs.getString(_roleKey);
    if (methodName == null || roleName == null) {
      return null;
    }

    SocialAuthMethod? method;
    for (final candidate in SocialAuthMethod.values) {
      if (candidate.name == methodName) {
        method = candidate;
        break;
      }
    }

    UserRole? role;
    for (final candidate in UserRole.values) {
      if (candidate.name == roleName) {
        role = candidate;
        break;
      }
    }

    if (method == null || role == null) {
      return null;
    }

    return PendingSocialAuth(method: method, role: role);
  }

  Future<void> clear() async {
    await _prefs.remove(_methodKey);
    await _prefs.remove(_roleKey);
  }
}

class SocialAuthNotifier extends AsyncNotifier<void> {
  late AuthRepository _repository;
  late PendingSocialAuthStore _pendingStore;

  @override
  FutureOr<void> build() {
    _repository = ref.read(authRepositoryProvider);
    _pendingStore = ref.read(pendingSocialAuthStoreProvider);
  }

  /// Fetches the OAuth redirect URL and saves the pending auth state.
  /// Returns the URL — the caller (UI) is responsible for opening it
  /// in the in-app WebView so the callback can be intercepted.
  Future<String> getSignInUrl({
    required SocialAuthMethod method,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    try {
      final authUrl = await _repository.getSocialAuthUrl(
        method: method,
        role: role,
      );
      await _pendingStore.save(method: method, role: role);
      state = const AsyncData(null);
      return authUrl;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<AuthResponse> completeFromCallback(Uri uri) async {
    state = const AsyncLoading();
    try {
      final callbackParameters = extractAuthCallbackParameters(uri);
      final callbackError =
          callbackParameters['error'] ?? callbackParameters['message'];
      if (callbackError != null &&
          callbackError.isNotEmpty &&
          !callbackParameters.containsKey('id')) {
        throw Exception(callbackError);
      }

      final pendingAuth = await _pendingStore.read();
      final method = SocialAuthMethod.fromUri(uri) ?? pendingAuth?.method;
      if (method == null) {
        throw Exception(
          'Unable to determine which social sign-in provider completed.',
        );
      }

      final id = callbackParameters['id'];
      final token = callbackParameters['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Social sign-in did not return the required token.');
      }

      final response = await _repository.exchangeSocialAuthToken(
        method: method,
        id: id,
        token: token,
      );
      if (!response.status ||
          response.data == null ||
          response.data!.token.isEmpty) {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : '${method.displayName} sign-in failed.',
        );
      }

      await ref
          .read(authProvider.notifier)
          .persistAuthenticatedResponse(response);
      ref.invalidate(emailVerificationStatusProvider);
      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } finally {
      await _pendingStore.clear();
    }
  }
}

Map<String, String> extractAuthCallbackParameters(Uri uri) {
  final parameters = <String, String>{...uri.queryParameters};
  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) {
    return parameters;
  }

  final queryFragment = fragment.startsWith('?')
      ? fragment.substring(1)
      : fragment.contains('=')
      ? fragment
      : null;
  if (queryFragment == null || queryFragment.isEmpty) {
    return parameters;
  }

  parameters.addAll(Uri.splitQueryString(queryFragment));
  return parameters;
}
