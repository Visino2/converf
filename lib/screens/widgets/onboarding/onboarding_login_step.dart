import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/core/config/shared_prefs_provider.dart';
import 'package:converf/core/ui/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../features/auth/models/auth_response.dart';
import '../../../features/auth/models/social_auth_method.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/providers/social_auth_provider.dart';
import '../../../features/auth/services/biometric_auth_service.dart';

class OnboardingLoginStep extends ConsumerStatefulWidget {
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final VoidCallback onBack;
  final String? selectedRole;

  const OnboardingLoginStep({
    super.key,
    required this.onSignup,
    required this.onForgotPassword,
    required this.onBack,
    this.selectedRole,
  });

  @override
  ConsumerState<OnboardingLoginStep> createState() =>
      _OnboardingLoginStepState();
}

class _OnboardingLoginStepState extends ConsumerState<OnboardingLoginStep> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _loginError;

  bool _biometricAvailable = false;
  String _biometricLabel = 'Biometrics';
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSavedEmail);
    Future.microtask(_checkBiometricAvailability);
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    if (!biometricService.isEnabledSync ||
        !biometricService.hasSavedCredentials)
      return;
    final availability = await biometricService.getAvailability();
    if (!mounted) return;
    if (availability.canAuthenticate) {
      setState(() {
        _biometricAvailable = true;
        _biometricLabel = availability.preferredLabel;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isBiometricLoading = true);
    try {
      final biometricService = ref.read(biometricAuthServiceProvider);
      final didAuth = await biometricService.authenticate(
        reason: 'Use $_biometricLabel to log back in to Converf.',
      );
      if (!mounted) return;
      if (!didAuth) {
        setState(() => _isBiometricLoading = false);
        return;
      }
      final ok = await ref.read(authProvider.notifier).loginWithBiometric();
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _isBiometricLoading = false;
          _biometricAvailable = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Session expired. Please log in with your email and password.',
            ),
          ),
        );
        return;
      }
      // Force refresh authProvider to trigger router redirect
      debugPrint(
        '[DEBUG] Biometric login successful, refreshing auth state...',
      );
      ref.invalidate(authProvider);
    } catch (e) {
      debugPrint('[DEBUG] Biometric login error: $e');
      if (mounted) setState(() => _isBiometricLoading = false);
    }
  }

  void _loadSavedEmail() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedEmail = prefs.getString('last_login_email');
    if (savedEmail != null && mounted) {
      _emailController.text = savedEmail;
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('last_login_email', email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loginError = null;
      _isEmailValid = false;
      _isPasswordValid = false;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final authNotifier = ref.read(authProvider.notifier);

      // Wait for the login operation to complete by watching the state
      await authNotifier.login(email, password);

      if (!mounted) return;

      // Now read the final state after login completes
      final authState = ref.read(authProvider);

      if (authState.hasError) {
        String error = authState.error.toString();
        if (error.contains('Exception:')) {
          error = error.replaceAll('Exception: ', '');
        }

        debugPrint('[Login] Error: $error');

        // Show as inline error if it seems identity-related
        if (error.toLowerCase().contains('invalid') ||
            error.toLowerCase().contains('email') ||
            error.toLowerCase().contains('password') ||
            error.toLowerCase().contains('found') ||
            error.toLowerCase().contains('credentials') ||
            error.toLowerCase().contains('unauthorized')) {
          setState(() => _loginError = 'Invalid email or password');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else if (authState.value?.status == true) {
        unawaited(_saveEmail(email));
        debugPrint('[Login] Success - router will redirect automatically');
      } else if (authState.value?.status == false) {
        setState(
          () => _loginError = authState.value?.message ?? 'Login failed',
        );
      } else {
        debugPrint('[Login] Unexpected state: ${authState.value}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loginError = 'Error: ${e.toString()}');
        debugPrint('[Login] Exception: $e');
      }
    }
  }

  Future<UserRole?> _resolveSocialRole() async {
    final initialRole = userRoleFromOnboardingSelection(widget.selectedRole);
    if (initialRole != null) {
      return initialRole;
    }

    return showModalBottomSheet<UserRole>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continue as',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose the account type you want to use for this sign-in.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 20),
                _buildRoleOptionTile(
                  title: 'Project Owner',
                  onTap: () => Navigator.of(context).pop(UserRole.projectOwner),
                ),
                const SizedBox(height: 12),
                _buildRoleOptionTile(
                  title: 'Contractor',
                  onTap: () => Navigator.of(context).pop(UserRole.contractor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSocialAuth(SocialAuthMethod method) async {
    final role = await _resolveSocialRole();
    if (role == null || !mounted) {
      return;
    }

    // Small delay to allow bottom sheet animation to finish before native SDK takes over.
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    try {
      if (method == SocialAuthMethod.google) {
        // Native Google Sign-In flow
        debugPrint(
          '[OnboardingLoginStep] Starting native Google Sign-In for role=${role.name} on ${defaultTargetPlatform.name}.',
        );
        final response = await ref
            .read(socialAuthActionProvider.notifier)
            .signInWithGoogleNative(role: role);

        if (response == null) {
          // User cancelled
          return;
        }

        // Success: authProvider state updated → router redirects to dashboard automatically.
      } else {
        // Apple: use the in-app WebView flow
        final authUrl = await ref
            .read(socialAuthActionProvider.notifier)
            .getSignInUrl(method: method, role: role);

        if (!mounted) return;

        final uri = Uri.parse(authUrl);
        debugPrint(
          '[OnboardingLoginStep] Launching external ${method.name} auth URL: $uri',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch the browser for signing in.');
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      debugPrintStack(
        label: '[OnboardingLoginStep] PlatformException during social auth',
        stackTrace: StackTrace.current,
      );
      // Do NOT fall back to the external browser — that sends users to the web app.
      // Show a clear error so the user knows to retry.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed (${e.code}). Please try again or contact support if this persists.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    bool isValid = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            if (label.contains('Email') && _loginError != null) {
              setState(() => _loginError = null);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            errorText: label.contains('Email') ? _loginError : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isValid &&
                    (label.contains('Email') ? _loginError == null : true))
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                if (isPassword)
                  IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF276572)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String title,
    required Widget iconWidget,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOptionTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF667085),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final socialAuthState = ref.watch(socialAuthActionProvider);

    return Container(
      key: const ValueKey('login'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45],
          colors: [AppColors.authShellTop, Colors.white],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onSignup,
                              child: const Text(
                                'Signup',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Log in to Converf',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome back! Please enter your details.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                'Email Address',
                                'you@example.com',
                                controller: _emailController,
                                isValid: _isEmailValid,
                                validator: (v) {
                                  if (v == null ||
                                      !v.contains('@') ||
                                      !v.contains('.')) {
                                    return 'Enter valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                'Password',
                                'Password',
                                controller: _passwordController,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onToggleVisibility: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                isValid: _isPasswordValid,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF276572),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            onPressed: authState.isLoading
                                ? null
                                : _handleLogin,
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: widget.onForgotPassword,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF276572),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        if (_biometricAvailable) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF276572),
                                ),
                                foregroundColor: const Color(0xFF276572),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _isBiometricLoading
                                  ? null
                                  : _handleBiometricLogin,
                              child: _isBiometricLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF276572),
                                      ),
                                    )
                                  : const Icon(Icons.fingerprint, size: 28),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _biometricLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF276572),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSocialButton(
                          title: 'Continue with Google',
                          iconWidget: Image.asset(
                            'assets/images/Google Icon.png',
                            width: 24,
                            height: 24,
                          ),
                          onTap: socialAuthState.isLoading
                              ? null
                              : () =>
                                    _handleSocialAuth(SocialAuthMethod.google),
                        ),
                        const SizedBox(height: 16),
                        _buildSocialButton(
                          title: 'Continue with Apple',
                          iconWidget: const Icon(
                            Icons.apple,
                            size: 28,
                            color: Colors.black,
                          ),
                          onTap: socialAuthState.isLoading
                              ? null
                              : () => _handleSocialAuth(SocialAuthMethod.apple),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
