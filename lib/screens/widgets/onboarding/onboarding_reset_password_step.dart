import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/core/ui/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class OnboardingResetPasswordStep extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;
  final String? initialEmail;
  final String? initialToken;

  const OnboardingResetPasswordStep({
    super.key,
    required this.onBackToLogin,
    this.initialEmail,
    this.initialToken,
  });

  @override
  ConsumerState<OnboardingResetPasswordStep> createState() =>
      _OnboardingResetPasswordStepState();
}

class _OnboardingResetPasswordStepState
    extends ConsumerState<OnboardingResetPasswordStep> {
  late final TextEditingController _emailController;
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _tokenController = TextEditingController(text: widget.initialToken);
  }

  bool _isEmailValid = false;
  bool _isTokenValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    await ref
        .read(authProvider.notifier)
        .resetPassword(
          email: email,
          token: token,
          password: password,
          passwordConfirmation: confirmPassword,
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authState.error.toString())));
      } else if (authState.value?.status == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.value?.message ?? 'Reset failed')),
        );
      } else if (authState.value?.status == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authState.value?.message ?? 'Password reset successful!',
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) widget.onBackToLogin();
        });
      }
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isValid)
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Container(
      key: const ValueKey('reset_password'),
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: widget.onBackToLogin,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Reset Password',
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
                          widget.initialEmail != null
                              ? 'Enter the 6-digit reset code sent to ${widget.initialEmail} and your new password.'
                              : 'Almost there! Enter your email, 6-digit reset code, and new password.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (widget.initialEmail == null) ...[
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
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (!_isEmailValid) {
                                        setState(() => _isEmailValid = true);
                                      }
                                    });
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildTextField(
                                'Reset Code',
                                'Enter 6-digit code',
                                controller: _tokenController,
                                isValid: _isTokenValid,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter token';
                                  }
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!_isTokenValid) {
                                      setState(() => _isTokenValid = true);
                                    }
                                  });
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                'New Password',
                                'Enter new password',
                                controller: _passwordController,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onToggleVisibility: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                isValid: _isPasswordValid,
                                validator: (v) {
                                  if (v == null || v.length < 8) {
                                    return 'Min 8 characters';
                                  }
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!_isPasswordValid) {
                                      setState(() => _isPasswordValid = true);
                                    }
                                  });
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                'Confirm New Password',
                                'Confirm new password',
                                controller: _confirmPasswordController,
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                onToggleVisibility: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                                isValid: _isConfirmPasswordValid,
                                validator: (v) {
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  if (v == null || v.isEmpty) {
                                    return 'Confirm password';
                                  }
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!_isConfirmPasswordValid) {
                                      setState(
                                        () => _isConfirmPasswordValid = true,
                                      );
                                    }
                                  });
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                                : _handleReset,
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
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const Spacer(flex: 3),
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
