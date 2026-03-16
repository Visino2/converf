import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';

class OnboardingAcceptInvitationStep extends ConsumerStatefulWidget {
  final String token;
  final VoidCallback onAccepted;
  final VoidCallback onBackToLogin;

  const OnboardingAcceptInvitationStep({
    super.key,
    required this.token,
    required this.onAccepted,
    required this.onBackToLogin,
  });

  @override
  ConsumerState<OnboardingAcceptInvitationStep> createState() =>
      _OnboardingAcceptInvitationStepState();
}

class _OnboardingAcceptInvitationStepState
    extends ConsumerState<OnboardingAcceptInvitationStep> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).acceptInvitation(
          token: widget.token,
          password: _passwordController.text.trim(),
          passwordConfirmation: _confirmPasswordController.text.trim(),
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } else if (authState.value?.status == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.value?.message ?? 'Failed to accept invitation'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (authState.value?.status == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.value?.message ?? 'Invitation accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAccepted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token.isEmpty) {
      return _buildInvalidInvitation();
    }

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Light gray background like Shadcn
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 512), // md:max-w-lg equivalent
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Accept Invitation',
                            style: TextStyle(
                              fontSize: 30, // text-3xl
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B1818),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Welcome to the team! Please set a password for your account.',
                            style: TextStyle(
                              fontSize: 12, // text-xs
                              color: Color(0xFF645D5D),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildTextField(
                            'Password',
                            'Enter your password',
                            controller: _passwordController,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            isValid: _isPasswordValid,
                            validator: (v) {
                              if (v == null || v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!_isPasswordValid) setState(() => _isPasswordValid = true);
                              });
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Confirm Password',
                            'Confirm your password',
                            controller: _confirmPasswordController,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () => setState(
                                () => _obscureConfirmPassword = !_obscureConfirmPassword),
                            isValid: _isConfirmPasswordValid,
                            validator: (v) {
                              if (v != _passwordController.text) {
                                return "Passwords don't match";
                              }
                              if (v == null || v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!_isConfirmPasswordValid)
                                  setState(() => _isConfirmPasswordValid = true);
                              });
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF18181B), // dark button
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: authState.isLoading ? null : _handleAccept,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Accept Invitation & Set Password',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                                ),
                                GestureDetector(
                                  onTap: widget.onBackToLogin,
                                  child: const Text(
                                    'Log in',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF18181B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvalidInvitation() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 448), // max-w-md
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invalid Invitation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // text-destructive
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This invitation link is missing or malformed. Please check your email and try again.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onBackToLogin,
                        child: const Text('Back to Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
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
                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                if (isPassword)
                  IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF18181B)),
            ),
          ),
        ),
      ],
    );
  }
}
