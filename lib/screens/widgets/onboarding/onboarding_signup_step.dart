import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class OnboardingSignupStep extends StatefulWidget {
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
  State<OnboardingSignupStep> createState() => _OnboardingSignupStepState();
}

class _OnboardingSignupStepState extends State<OnboardingSignupStep> {
  String? _selectedCountry;
  bool _agreedToTerms = false;

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
    bool isPassword = false,
    Widget? trailing,
    bool readOnly = false,
    VoidCallback? onTap,
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
          obscureText: isPassword,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: trailing,
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
                  separatorBuilder: (_, __) =>
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
                        setState(() => _selectedCountry = country);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
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
                    child: _buildTextField('First Name', 'you@example.com'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Last Name', 'you@example.com'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Email Address', 'you@example.com'),
              const SizedBox(height: 12),
              _buildTextField(
                'Country',
                _selectedCountry ?? 'Select Country',
                readOnly: true,
                onTap: _showCountryPicker,
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Password',
                'Password',
                isPassword: true,
                trailing: const Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Confirm Password',
                'Password',
                isPassword: true,
                trailing: const Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
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
                  onPressed: widget.onSignupSubmit,
                  child: const Text(
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
                                'Yes, I understand and agree to the Converf\\n',
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
