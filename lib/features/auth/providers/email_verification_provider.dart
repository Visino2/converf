import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response.dart';
import '../models/email_verification_status.dart';
import '../repositories/auth_repository.dart';
import 'auth_provider.dart';

final emailVerificationStatusProvider = FutureProvider<EmailVerificationStatus>(
  (ref) async {
    final authState = ref.watch(authProvider);
    if (authState.isLoading) {
      return EmailVerificationStatus.unknown;
    }

    final authResponse = authState.asData?.value;
    final isAuthenticated =
        authResponse != null &&
        authResponse.status &&
        authResponse.data != null &&
        authResponse.data!.token.isNotEmpty;

    if (!isAuthenticated) {
      return EmailVerificationStatus.unknown;
    }

    final repository = ref.read(authRepositoryProvider);
    return repository.checkEmailVerificationStatus(
      cachedUser: authResponse.data!.user,
    );
  },
);

final pendingEmailVerificationLinkStoreProvider =
    Provider<PendingEmailVerificationLinkStore>((ref) {
      return PendingEmailVerificationLinkStore();
    });

class PendingEmailVerificationLink {
  const PendingEmailVerificationLink({
    this.id,
    this.hash,
    this.verifyUrl,
    this.queryParameters = const <String, String>{},
  });

  final String? id;
  final String? hash;
  final String? verifyUrl;
  final Map<String, String> queryParameters;

  bool get hasVerificationPayload {
    final hasDirectPayload =
        id != null && id!.isNotEmpty && hash != null && hash!.isNotEmpty;
    final hasVerifyUrl = verifyUrl != null && verifyUrl!.trim().isNotEmpty;
    return hasDirectPayload || hasVerifyUrl;
  }
}

class PendingEmailVerificationLinkStore {
  static const _idKey = 'pending_email_verification_id';
  static const _hashKey = 'pending_email_verification_hash';
  static const _verifyUrlKey = 'pending_email_verification_verify_url';
  static const _queryParametersKey =
      'pending_email_verification_query_parameters';

  Future<void> save({
    String? id,
    String? hash,
    String? verifyUrl,
    Map<String, String> queryParameters = const <String, String>{},
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (id != null && id.trim().isNotEmpty) {
      await prefs.setString(_idKey, id.trim());
    } else {
      await prefs.remove(_idKey);
    }

    if (hash != null && hash.trim().isNotEmpty) {
      await prefs.setString(_hashKey, hash.trim());
    } else {
      await prefs.remove(_hashKey);
    }

    if (verifyUrl != null && verifyUrl.trim().isNotEmpty) {
      await prefs.setString(_verifyUrlKey, verifyUrl.trim());
    } else {
      await prefs.remove(_verifyUrlKey);
    }

    if (queryParameters.isNotEmpty) {
      await prefs.setString(_queryParametersKey, jsonEncode(queryParameters));
    } else {
      await prefs.remove(_queryParametersKey);
    }
  }

  Future<void> saveFromUri(Uri uri) async {
    final queryParameters = <String, String>{...uri.queryParameters};
    final pathSegments = uri.pathSegments;

    String? id = queryParameters['id'];
    String? hash = queryParameters['hash'];
    if (uri.path.startsWith('/auth/email/verify/') &&
        pathSegments.length >= 5) {
      id ??= pathSegments[3];
      hash ??= pathSegments[4];
    }

    await save(
      id: id,
      hash: hash,
      verifyUrl: queryParameters['verify_url'],
      queryParameters: queryParameters,
    );
  }

  Future<PendingEmailVerificationLink?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final queryParametersJson = prefs.getString(_queryParametersKey);
    Map<String, String> queryParameters = const <String, String>{};

    if (queryParametersJson != null && queryParametersJson.isNotEmpty) {
      final decoded = jsonDecode(queryParametersJson);
      if (decoded is Map) {
        queryParameters = decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    final link = PendingEmailVerificationLink(
      id: prefs.getString(_idKey),
      hash: prefs.getString(_hashKey),
      verifyUrl: prefs.getString(_verifyUrlKey),
      queryParameters: queryParameters,
    );

    return link.hasVerificationPayload ? link : null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_hashKey);
    await prefs.remove(_verifyUrlKey);
    await prefs.remove(_queryParametersKey);
  }
}

class EmailVerificationActionNotifier extends AsyncNotifier<void> {
  late AuthRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(authRepositoryProvider);
  }

  Future<String> resendVerificationEmail() async {
    state = const AsyncLoading();
    try {
      final response = await _repository.resendVerificationEmail();
      ref.invalidate(emailVerificationStatusProvider);
      state = const AsyncData(null);
      return response.message;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<String> verifyEmailLink({
    required String id,
    required String hash,
    Map<String, dynamic>? queryParameters,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.verifyEmail(
        id: id,
        hash: hash,
        queryParameters: queryParameters,
      );
      await ref
          .read(authProvider.notifier)
          .markEmailVerified(verifiedAt: _extractVerifiedAt(response));
      await ref.read(pendingEmailVerificationLinkStoreProvider).clear();
      ref.invalidate(emailVerificationStatusProvider);
      state = const AsyncData(null);
      return response.message;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<String> sendOtp() async {
    state = const AsyncLoading();
    try {
      final response = await _repository.sendEmailVerificationOtp();
      state = const AsyncData(null);
      return response.message;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<String> verifyOtp(String code) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.verifyEmailOtp(code);
      await ref
          .read(authProvider.notifier)
          .markEmailVerified(verifiedAt: _extractVerifiedAt(response));
      ref.invalidate(emailVerificationStatusProvider);
      state = const AsyncData(null);
      return response.message;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<EmailVerificationStatus> refreshVerificationStatus() async {
    ref.invalidate(emailVerificationStatusProvider);
    return ref.read(emailVerificationStatusProvider.future);
  }

  String? _extractVerifiedAt(AuthResponse response) {
    final user = response.data?.user;
    final candidates = [
      user?['email_verified_at'],
      user?['emailVerifiedAt'],
      user?['verified_at'],
      user?['verifiedAt'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}

final emailVerificationActionProvider =
    AsyncNotifierProvider<EmailVerificationActionNotifier, void>(
      EmailVerificationActionNotifier.new,
    );
