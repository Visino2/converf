import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/config.dart';
import '../../../core/ui/app_navigation.dart';
import '../../../core/ui/app_scaffold_messenger.dart';
import '../../ai_credits/providers/ai_credits_provider.dart';
import '../models/auth_response.dart';
import '../models/email_verification_status.dart';
import '../providers/auth_provider.dart';
import '../../billing/providers/billing_providers.dart';
import '../providers/email_verification_provider.dart';
import '../providers/social_auth_provider.dart';
import '../utils/auth_flow.dart';

final authAppLinksServiceProvider = Provider<AuthAppLinksService>((ref) {
  return AuthAppLinksService(ref);
});

class AuthAppLinksService {
  AuthAppLinksService(this._ref);

  static const Set<String> _acceptedHttpsHosts = <String>{
    'converf-fe.netlify.app',
    'converf.io',
    'www.converf.io',
  };
  static const Set<String> _billingPathKeywords = <String>{
    'billing',
    'payment',
    'subscription',
    'callback',
    'success',
    'complete',
    'verify',
  };
  static const Set<String> _billingReferenceKeys = <String>{
    'reference',
    'trxref',
    'tx_ref',
    'transaction_id',
  };

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

    if (_isAcceptInvitationLink(uri)) {
      final token = extractAuthCallbackParameters(uri)['token'];
      _navigate(router, acceptInvitationLocation(token: token));
      return;
    }

    if (await _tryHandleBillingCallback(uri, router)) {
      return;
    }

    if (await _tryHandleSocialCallback(uri, router)) {
      return;
    }

    if (_isResetPasswordLink(uri)) {
      _navigate(router, '/auth/reset-password${_querySuffix(uri)}');
      return;
    }

    if (_isVerifyEmailLink(uri)) {
      final normalizedPath = _normalizedPath(uri);
      final targetPath = normalizedPath.startsWith('/auth/email/verify/')
          ? normalizedPath
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

    if (_isResetPasswordLink(uri) ||
        _isVerifyEmailLink(uri) ||
        _isAcceptInvitationLink(uri)) {
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

  Future<bool> _tryHandleBillingCallback(Uri uri, GoRouter router) async {
    final parameters = _billingCallbackParameters(uri);
    final pendingReference = _ref.read(pendingPaymentReferenceProvider);
    final callbackReference = _extractBillingReference(parameters);

    if (!_looksLikeBillingCallback(
      uri,
      parameters,
      hasPendingReference:
          pendingReference != null || callbackReference != null,
    )) {
      return false;
    }

    final status = parameters['status'];
    if (_isBillingFailureStatus(status)) {
      _ref.read(pendingPaymentReferenceProvider.notifier).clear();
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Payment was cancelled or not completed.'),
        ),
      );
      return true;
    }

    final reference = pendingReference ?? callbackReference;

    try {
      if (reference != null && reference.isNotEmpty) {
        await _ref.read(billingActionProvider.notifier).verify(reference);
      } else {
        await _refreshBillingState();
      }

      _ref.read(pendingPaymentReferenceProvider.notifier).clear();
      _navigateAfterBillingSuccess(router);
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Payment confirmed. Your plan is now updated.'),
        ),
      );
    } catch (_) {
      _ref.read(pendingPaymentReferenceProvider.notifier).clear();
      await _refreshBillingState();
      _navigateAfterBillingSuccess(router);
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Payment received. Refreshing your plan on the dashboard.',
          ),
        ),
      );
    }

    return true;
  }

  bool _isConverfLink(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'converf') {
      return true;
    }
    if (scheme != 'https' && scheme != 'http') {
      return false;
    }

    final host = uri.host.toLowerCase();
    final apiHost = Uri.tryParse(AppConfig.apiBaseUrl)?.host.toLowerCase();
    return _acceptedHttpsHosts.contains(host) || host == apiHost;
  }

  bool _isResetPasswordLink(Uri uri) {
    return _normalizedPath(uri).contains('/auth/reset-password');
  }

  bool _isVerifyEmailLink(Uri uri) {
    final normalizedPath = _normalizedPath(uri);
    return normalizedPath.contains('/auth/verify-email') ||
        normalizedPath.contains('/auth/email/verify/');
  }

  bool _isAcceptInvitationLink(Uri uri) {
    return _normalizedPath(uri).contains('/accept-invitation');
  }

  String _normalizedPath(Uri uri) {
    if (uri.scheme.toLowerCase() == 'converf' && uri.host.isNotEmpty) {
      return '/${uri.host}${uri.path}';
    }
    return uri.path;
  }

  bool _looksLikeBillingCallback(
    Uri uri,
    Map<String, String> parameters, {
    required bool hasPendingReference,
  }) {
    if (!hasPendingReference) {
      return false;
    }

    final normalizedPath = _normalizedPath(uri).toLowerCase();
    final status = parameters['status'];

    if (_billingPathKeywords.any(normalizedPath.contains)) {
      return true;
    }

    if (status != null && status.isNotEmpty) {
      return true;
    }

    return parameters.keys.any(_billingReferenceKeys.contains);
  }

  Map<String, String> _billingCallbackParameters(Uri uri) {
    final parameters = <String, String>{
      ...uri.queryParameters.map(
        (key, value) => MapEntry(key.toLowerCase(), value.toLowerCase()),
      ),
    };
    final fragment = uri.fragment.trim();

    if (!fragment.contains('=')) {
      return parameters;
    }

    try {
      parameters.addAll(
        Uri.splitQueryString(
          fragment,
        ).map((key, value) => MapEntry(key.toLowerCase(), value.toLowerCase())),
      );
    } catch (_) {
      return parameters;
    }

    return parameters;
  }

  String? _extractBillingReference(Map<String, String> parameters) {
    for (final key in _billingReferenceKeys) {
      final value = parameters[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  bool _isBillingFailureStatus(String? status) {
    return status == 'failed' ||
        status == 'failure' ||
        status == 'cancelled' ||
        status == 'canceled';
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

  void _navigateAfterBillingSuccess(GoRouter router) {
    appNavigatorKey.currentState?.popUntil((route) => route.isFirst);

    final authResponse = _ref.read(authProvider).asData?.value;
    final dashboardLocation = dashboardLocationForRole(
      authResponse?.role ?? UserRole.unknown,
      tab: 'dashboard',
    );

    if (dashboardLocation != null) {
      _navigate(router, dashboardLocation);
    }
  }

  Future<void> _refreshBillingState() async {
    _ref.invalidate(billingSubscriptionProvider);
    _ref.invalidate(billingTransactionsProvider);
    _ref.invalidate(aiCreditsProvider);

    try {
      await _ref.read(billingSubscriptionProvider.future);
    } catch (_) {
      // Let the dashboard/billing UI retry naturally if this refresh fails.
    }
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
