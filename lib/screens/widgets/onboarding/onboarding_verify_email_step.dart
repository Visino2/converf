import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:converf/core/ui/app_colors.dart';

import '../../../features/auth/models/auth_response.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/providers/email_verification_provider.dart';
import '../../../features/auth/utils/auth_flow.dart';
import 'dart:async';

class OnboardingVerifyEmailStep extends ConsumerStatefulWidget {
  const OnboardingVerifyEmailStep({
    super.key,
    this.email,
    this.autoResend = false,
    this.verifyUrl,
    this.verificationId,
    this.verificationHash,
    this.verificationQueryParameters = const <String, String>{},
  });

  final String? email;
  final bool autoResend;
  final String? verifyUrl;
  final String? verificationId;
  final String? verificationHash;
  final Map<String, String> verificationQueryParameters;

  @override
  ConsumerState<OnboardingVerifyEmailStep> createState() =>
      _OnboardingVerifyEmailStepState();
}

class _OnboardingVerifyEmailStepState
    extends ConsumerState<OnboardingVerifyEmailStep> {
  bool _hasHandledInitialAction = false;
  String? _inlineMessage;
  bool _inlineMessageIsError = false;
  final TextEditingController _otpController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = 0;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialAction();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _handleInitialAction() async {
    if (_hasHandledInitialAction) {
      return;
    }
    _hasHandledInitialAction = true;

    final pendingLink = await ref
        .read(pendingEmailVerificationLinkStoreProvider)
        .read();
    final request = _resolveVerificationRequest(pendingLink);

    if (request != null) {
      await _attemptAutoVerification(request);
      await ref.read(pendingEmailVerificationLinkStoreProvider).clear();
      return;
    }

    // Always send OTP on initial load if not already verified
    await _handleSendOtp(isInitial: true);
  }

  Future<void> _handleSendOtp({bool isInitial = false}) async {
    if (_isSendingOtp || _secondsRemaining > 0) return;
    
    setState(() {
      _isSendingOtp = true;
      if (!isInitial) {
        _inlineMessage = 'Sending a new code...';
        _inlineMessageIsError = false;
      }
    });

    try {
      final message = await ref
          .read(emailVerificationActionProvider.notifier)
          .sendOtp();
      
      if (!mounted) return;

      setState(() {
        _isSendingOtp = false;
        _inlineMessage = message;
        _inlineMessageIsError = false;
      });
      _startResendTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _inlineMessage = e.toString();
        _inlineMessageIsError = true;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() {
        _inlineMessage = 'Please enter a 6-digit code';
        _inlineMessageIsError = true;
      });
      return;
    }

    try {
      final message = await ref
          .read(emailVerificationActionProvider.notifier)
          .verifyOtp(code);
      
      if (!mounted) return;

      setState(() {
        _inlineMessage = message;
        _inlineMessageIsError = false;
      });
      _goToRoleDestination();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _inlineMessage = e.toString();
        _inlineMessageIsError = true;
      });
    }
  }

  Future<void> _attemptAutoVerification(_VerificationRequest request) async {
    try {
      final message = await ref
          .read(emailVerificationActionProvider.notifier)
          .verifyEmailLink(
            id: request.id,
            hash: request.hash,
            queryParameters: Map<String, dynamic>.from(request.queryParameters),
          );

      if (!context.mounted) {
        return;
      }

      setState(() {
        _inlineMessage = message;
        _inlineMessageIsError = false;
      });
      _goToRoleDestination();
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      setState(() {
        _inlineMessage = e.toString();
        _inlineMessageIsError = true;
      });
    }
  }

  // ignore: unused_element
  Future<void> _attemptAutoResend() async {
    final authState = ref.read(authProvider);
    final authResponse = authState.asData?.value;
    final isAuthenticated =
        authResponse != null &&
        authResponse.status &&
        authResponse.data != null &&
        authResponse.data!.token.isNotEmpty;

    if (!isAuthenticated) {
      return;
    }

    try {
      final message = await ref
          .read(emailVerificationActionProvider.notifier)
          .resendVerificationEmail();
      if (!mounted) {
        return;
      }

      setState(() {
        _inlineMessage = message;
        _inlineMessageIsError = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _inlineMessage = e.toString();
        _inlineMessageIsError = true;
      });
    }
  }



  // ignore: unused_element
  Future<void> _handleRefreshStatus() async {
    setState(() {
      _inlineMessage = 'Refreshing status...';
      _inlineMessageIsError = false;
    });

    try {
      // 1. Invalidate status to force a fresh API check
      ref.invalidate(emailVerificationStatusProvider);
      
      // 2. Wait for the provider to update
      final status = await ref.read(emailVerificationStatusProvider.future);
      
      if (!context.mounted) return;

      if (status.isVerified) {
        _goToRoleDestination();
      } else {
        setState(() {
          _inlineMessage = 'Your email is still showing as unverified. Please check your inbox and click the link.';
          _inlineMessageIsError = true;
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _inlineMessage = 'Failed to refresh status. Please try again.';
        _inlineMessageIsError = true;
      });
    }
  }

  // ignore: unused_element
  Future<void> _handleBypassVerification() async {
    // This mimics the WebApp's behavior of forcing a local verified state
    // when the backend fails to save the timestamp correctly.
    await ref.read(authProvider.notifier).markEmailVerified();
    if (!context.mounted) return;
    _goToRoleDestination();
  }

  Future<void> _handleLogout() async {
    final router = GoRouter.of(context);
    await ref.read(pendingEmailVerificationLinkStoreProvider).clear();
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }
    router.go(onboardingLocation(login: true));
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(emailVerificationActionProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        key: const ValueKey('verify_email'),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45],
            colors: [AppColors.authShellTop, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade500,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Email Verification!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the 6-digit code sent to your email address to verify your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade300,
                          letterSpacing: 12,
                        ),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 6) {
                          _handleVerifyOtp();
                        }
                      },
                    ),
                    if (_inlineMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _inlineMessageIsError
                              ? const Color(0xFFFFF2F0)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _inlineMessageIsError
                                ? const Color(0xFFFECACA)
                                : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Text(
                          _inlineMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: _inlineMessageIsError
                                ? const Color(0xFFB42318)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                    if (actionState.isLoading || _isSendingOtp) ...[
                      const SizedBox(height: 32),
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _handleVerifyOtp,
                          child: const Text(
                            'Verify Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _secondsRemaining > 0 ? null : () => _handleSendOtp(),
                        child: Text(
                          _secondsRemaining > 0
                              ? 'Resend code in ${_secondsRemaining}s'
                              : 'Resend verification code',
                          style: TextStyle(
                            color: _secondsRemaining > 0
                                ? Colors.grey
                                : const Color(0xFFF97316),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _handleLogout,
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _VerificationRequest? _resolveVerificationRequest(
    PendingEmailVerificationLink? pendingLink,
  ) {
    final directRequest = _requestFromParts(
      id: widget.verificationId,
      hash: widget.verificationHash,
      queryParameters: widget.verificationQueryParameters,
    );
    if (directRequest != null) {
      return directRequest;
    }

    final verifyUrlRequest = _requestFromVerifyUrl(
      widget.verifyUrl,
      fallbackQueryParameters: widget.verificationQueryParameters,
    );
    if (verifyUrlRequest != null) {
      return verifyUrlRequest;
    }

    if (pendingLink == null) {
      return null;
    }

    final pendingDirectRequest = _requestFromParts(
      id: pendingLink.id,
      hash: pendingLink.hash,
      queryParameters: pendingLink.queryParameters,
    );
    if (pendingDirectRequest != null) {
      return pendingDirectRequest;
    }

    return _requestFromVerifyUrl(
      pendingLink.verifyUrl,
      fallbackQueryParameters: pendingLink.queryParameters,
    );
  }

  _VerificationRequest? _requestFromParts({
    required String? id,
    required String? hash,
    required Map<String, String> queryParameters,
  }) {
    if (id == null || id.isEmpty || hash == null || hash.isEmpty) {
      return null;
    }

    return _VerificationRequest(
      id: id,
      hash: hash,
      queryParameters: Map<String, String>.from(queryParameters),
    );
  }

  _VerificationRequest? _requestFromVerifyUrl(
    String? verifyUrl, {
    required Map<String, String> fallbackQueryParameters,
  }) {
    final normalizedUrl = verifyUrl?.trim() ?? '';
    if (normalizedUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.length < 5 ||
        segments[0] != 'auth' ||
        segments[1] != 'email') {
      return null;
    }

    final mergedQueryParameters = <String, String>{
      ...uri.queryParameters,
      ...fallbackQueryParameters,
    };

    return _VerificationRequest(
      id: segments[3],
      hash: segments[4],
      queryParameters: mergedQueryParameters,
    );
  }

  void _goToRoleDestination() {
    final authResponse = ref.read(authProvider).asData?.value;
    final dashboardRoute = dashboardRouteForRole(
      authResponse?.role ?? UserRole.unknown,
    );
    if (dashboardRoute == null || !mounted) {
      return;
    }

    context.go(dashboardRoute);
  }
}

class _VerificationRequest {
  const _VerificationRequest({
    required this.id,
    required this.hash,
    required this.queryParameters,
  });

  final String id;
  final String hash;
  final Map<String, String> queryParameters;
}
