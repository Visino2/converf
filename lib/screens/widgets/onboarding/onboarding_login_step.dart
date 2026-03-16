import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

class OnboardingLoginStep extends ConsumerStatefulWidget {
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final VoidCallback onBack;

  const OnboardingLoginStep({
    super.key,
    required this.onSignup,
    required this.onForgotPassword,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingLoginStep> createState() => _OnboardingLoginStepState();
}

class _OnboardingLoginStepState extends ConsumerState<OnboardingLoginStep> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _loginError;

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
    final password = _passwordController.text.trim();

    await ref.read(authProvider.notifier).login(email, password);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        String error = authState.error.toString();
        if (error.contains('Exception:')) {
          error = error.replaceAll('Exception: ', '');
        }
        
        // Show as inline error if it seems identity-related
        if (error.toLowerCase().contains('invalid') || error.toLowerCase().contains('email') || error.toLowerCase().contains('password') || error.toLowerCase().contains('found') || error.toLowerCase().contains('credentials')) {
          setState(() => _loginError = 'Invalid email or password');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (authState.value?.status == false) {
        setState(() => _loginError = authState.value?.message ?? 'Login failed');
      } else {
        // Login succeeded — show checkmarks!
        setState(() {
          _isEmailValid = true;
          _isPasswordValid = true;
        });
      }
      // Success is handled by AppRouter redirection
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
                if (isValid && (label.contains('Email') ? _loginError == null : true))
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Container(
      key: const ValueKey('login'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45],
          colors: [Color(0xFF276572), Colors.white],
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
                                  if (v == null || !v.contains('@') || !v.contains('.')) return 'Enter valid email';
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
                                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                isValid: _isPasswordValid,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter password';
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
                            onPressed: authState.isLoading ? null : _handleLogin,
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
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildSocialButton(
                          title: 'Continue with Apple',
                          iconWidget: const Icon(
                            Icons.apple,
                            size: 28,
                            color: Colors.black,
                          ),
                          onTap: () {},
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
