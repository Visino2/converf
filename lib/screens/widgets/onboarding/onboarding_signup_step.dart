import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/models/product_owner_register_request.dart';

class OnboardingSignupStep extends ConsumerStatefulWidget {
  final VoidCallback onSignupSubmit;
  final VoidCallback onBack;
  final VoidCallback onLogin;

  const OnboardingSignupStep({
    super.key,
    required this.onSignupSubmit,
    required this.onBack,
    required this.onLogin,
  });

  @override
  ConsumerState<OnboardingSignupStep> createState() => _OnboardingSignupStepState();
}

class _OnboardingSignupStepState extends ConsumerState<OnboardingSignupStep> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  String? _selectedCountry;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailBackendError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  Future<void> _handleSignup() async {
    setState(() => _emailBackendError = null);
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }

    final request = ProductOwnerRegisterRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      country: _selectedCountry ?? '',
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    await ref.read(authProvider.notifier).registerOwner(request);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        String error = authState.error.toString();
        if (error.contains('Exception:')) {
          error = error.replaceAll('Exception: ', '');
        }
        
        // Specifically check for "already registered" or "email taken"
        if (error.toLowerCase().contains('email') && (error.toLowerCase().contains('taken') || error.toLowerCase().contains('registered') || error.toLowerCase().contains('exists'))) {
           setState(() => _emailBackendError = 'This email is already registered');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.value?.message ?? 'Registration failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // Success is handled by AppRouter redirection
    }
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _TermsOfServiceModal(),
    );
  }

  void _showPrivacyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _PrivacyPolicyModal(),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    bool isValid = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            if (label.contains('Email') && _emailBackendError != null) {
              setState(() => _emailBackendError = null);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            errorText: label.contains('Email') ? _emailBackendError : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isValid && (label.contains('Email') ? _emailBackendError == null : true))
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
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF276572), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    final countries = [
      'Nigeria',
      'Ghana',
      'Kenya',
      'South Africa',
      'Egypt',
      'Ethiopia',
      'Tanzania',
      'Uganda',
      'Rwanda',
      'Senegal',
      'Other African Country',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Select your country',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: countries.length,
                  separatorBuilder: (_, index) =>
                      const Divider(height: 1, indent: 24, endIndent: 24),
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      title: Text(
                        country,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Container(
      key: const ValueKey('signup'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3],
          colors: [Color(0xFF276572), Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onLogin,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
              const Text(
                'Get started with\nConverf',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build world-class infrastructure across Africa',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'First Name',
                      'David',
                      controller: _firstNameController,
                      validator: (v) {
                        if (v == null || v.length < 2) return 'Enter first name';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Last Name',
                      'Fayemi',
                      controller: _lastNameController,
                      validator: (v) {
                        if (v == null || v.length < 2) return 'Enter last name';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Email Address',
                'you@example.com',
                controller: _emailController,
                isValid: _isEmailValid,
                validator: (v) {
                  if (v == null || !v.contains('@') || !v.contains('.')) return 'Enter valid email';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_isEmailValid) setState(() => _isEmailValid = true);
                  });
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Country',
                _selectedCountry ?? 'Select Country',
                controller: TextEditingController(text: _selectedCountry ?? ''),
                readOnly: true,
                onTap: _showCountryPicker,
                validator: (v) {
                  if (_selectedCountry == null) return 'Select country';
                  return null;
                },
                onToggleVisibility: null,
                isPassword: false,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Password',
                'Password',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                isValid: _isPasswordValid,
                validator: (v) {
                  if (v == null || v.length < 8) return 'Min 8 characters';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_isPasswordValid) setState(() => _isPasswordValid = true);
                  });
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Confirm Password',
                'Password',
                controller: _confirmPasswordController,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (v) {
                  if (v != _passwordController.text) return 'Passwords do not match';
                  if (v == null || v.isEmpty) return 'Confirm password';
                  return null;
                },
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
                  onPressed: authState.isLoading ? null : _handleSignup,
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
                          'Signup',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                      activeColor: const Color(0xFF276572),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Yes, I understand and agree to the Converf\n',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: Color(0xFF276572),
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _showTermsModal,
                          ),
                          const TextSpan(text: ', including the '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Color(0xFF276572),
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _showPrivacyModal,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _TermsOfServiceModal extends StatelessWidget {
  const _TermsOfServiceModal();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Terms of Service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balancing so title centers naturally
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(
              '''Effective Date: February 5, 2026
Last Updated: February 5, 2026

1. ACCEPTANCE OF TERMS
Welcome to Converf. These Terms of Service ("Terms") govern your access to and use of the Converf platform, website, and services (collectively, the "Platform"). By creating an account, accessing, or using Converf, you agree to be bound by these Terms.

If you do not agree to these Terms, you may not access or use the Platform.

Converf Technologies Limited ("Converf", "we," "us," or "our") reserves the right to modify these Terms at any time. We will notify users of material changes via email or through the Platform. Your continued use after such modifications constitutes acceptance of the updated Terms.

2. PLATFORM OVERVIEW
2.1 Services Provided
Converf is a Pan-African construction management platform that provides:
• Intelligent quality assurance and quality control (QA/QC) systems
• Real-time quality scoring algorithms (0-100% scale)
• Ball-in-Court accountability tracking
• Multi-phase construction project management
• Automated certificate generation upon project completion
• Standards compliance tools (ASTM, ISO, AASHTO, and regional standards)
• Document management and collaboration tools
• Traffic light quality monitoring system

2.2 Geographic Scope
Converf operates across all 54 African countries.''',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyPolicyModal extends StatelessWidget {
  const _PrivacyPolicyModal();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balancing so title centers naturally
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Text(
              '''Effective Date: February 5, 2026
Last Updated: February 5, 2026

1. INTRODUCTION
Converf Technologies Limited ("Converf," "we," "us," or "our") is committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Platform.

1.1 Scope
This Privacy Policy applies to all users of the Converf platform, including:
• Project Owners managing construction projects
• Contractors and builders executing projects
• Team members and collaborators
• Visitors to our website

1.2 Pan-African Operations
Converf operates across all 54 African countries. This Privacy Policy is designed to comply with data protection laws across our operating regions, including but not limited to:
• Nigeria Data Protection Regulation (NDPR)
• South Africa's Protection of Personal Information Act (POPIA)
• Kenya Data Protection Act
• Ghana Data Protection Act
• Other applicable national data protection laws

1.3 Consent
By using Converf, you consent to the collection, use, and disclosure of your information as described in this Privacy Policy. If you do not agree, please do not use the Platform.

2. INFORMATION WE COLLECT
2.1 Information You Provide Directly
Account Information:''',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
