import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_scaffold_messenger.dart';
import '../models/auth_response.dart';
import '../models/email_verification_status.dart';
import '../providers/auth_provider.dart';
import '../providers/email_verification_provider.dart';
import '../providers/social_auth_provider.dart';
import '../utils/auth_flow.dart';

final authAppLinksServiceProvider = Provider<AuthAppLinksService>((ref) {
  return AuthAppLinksService(ref);
});

class AuthAppLinksService {
  AuthAppLinksService(this._ref);

  final Ref _ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _initialized = false;

  Future<void> initialize(GoRouter router) async {
    if (_initialized || _subscription != null) {
      return;
    }
    _initialized = true;

    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleUri(initialLink, router);
      }
    } catch (e) {
      debugPrint('[AuthLinks] Failed to read initial app link: $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        unawaited(_handleUri(uri, router));
      },
      onError: (Object error) {
        debugPrint('[AuthLinks] Incoming app link failed: $error');
      },
    );
  }

  Future<void> _handleUri(Uri uri, GoRouter router) async {
    if (!_isConverfLink(uri)) {
      return;
    }

    if (_isVerifyEmailLink(uri)) {
      final authState = _ref.read(authProvider);
      final authResponse = authState.asData?.value;
      final isAuthenticated =
          authResponse != null &&
          authResponse.status &&
          authResponse.data != null &&
          authResponse.data!.token.isNotEmpty;

      if (!isAuthenticated) {
        await _ref
            .read(pendingEmailVerificationLinkStoreProvider)
            .saveFromUri(uri);
        _navigate(router, onboardingLocation(login: true));
        return;
      }
    }

    if (await _tryHandleSocialCallback(uri, router)) {
      return;
    }

    if (_isResetPasswordLink(uri)) {
      _navigate(router, '/auth/reset-password${_querySuffix(uri)}');
      return;
    }

    if (_isVerifyEmailLink(uri)) {
      final targetPath = uri.path.startsWith('/auth/email/verify/')
          ? uri.path
          : '/auth/verify-email';
      _navigate(router, '$targetPath${_querySuffix(uri)}');
    }
  }

  Future<bool> _tryHandleSocialCallback(Uri uri, GoRouter router) async {
    final parameters = extractAuthCallbackParameters(uri);
    final hasOtpPayload =
        parameters.containsKey('id') || parameters.containsKey('token');
    final hasCallbackError =
        parameters.containsKey('error') || parameters.containsKey('message');
    if (!hasOtpPayload && !hasCallbackError) {
      return false;
    }

    if (_isResetPasswordLink(uri) || _isVerifyEmailLink(uri)) {
      return false;
    }

    try {
      final response = await _ref
          .read(socialAuthActionProvider.notifier)
          .completeFromCallback(uri);
      final verificationStatus = await _resolveVerificationStatus(response);
      final dashboardRoute = dashboardRouteForRole(response.role);

      if (verificationStatus == EmailVerificationStatus.unverified) {
        _navigate(
          router,
          verifyEmailLocation(
            email: response.data?.user['email']?.toString(),
            autoResend: true,
          ),
        );
      } else if (dashboardRoute != null) {
        _navigate(router, dashboardRoute);
      } else {
        _navigate(router, onboardingLocation(login: true));
      }

      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    } catch (e) {
      _navigate(router, onboardingLocation(login: true));
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    return true;
  }

  bool _isConverfLink(Uri uri) {
    return uri.host == 'converf-fe.netlify.app';
  }

  bool _isResetPasswordLink(Uri uri) {
    return uri.path.contains('/auth/reset-password');
  }

  bool _isVerifyEmailLink(Uri uri) {
    return uri.path.contains('/auth/verify-email') ||
        uri.path.contains('/auth/email/verify/');
  }

  String _querySuffix(Uri uri) {
    final parameters = extractAuthCallbackParameters(uri);
    if (parameters.isEmpty) {
      return '';
    }
    return '?${Uri(queryParameters: parameters).query}';
  }

  void _navigate(GoRouter router, String location) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(location);
    });
  }

  Future<EmailVerificationStatus> _resolveVerificationStatus(
    AuthResponse response,
  ) async {
    final cachedStatus = emailVerificationStatusFromPayload(
      response.data?.user,
    );
    if (cachedStatus.isKnown) {
      return cachedStatus;
    }

    return _ref.read(emailVerificationStatusProvider.future);
  }
}
