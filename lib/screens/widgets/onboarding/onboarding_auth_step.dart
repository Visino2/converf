import 'package:flutter/material.dart';

class OnboardingAuthStep extends StatelessWidget {
  final VoidCallback onSignupManually;
  final VoidCallback onLogin;

  const OnboardingAuthStep({
    super.key,
    required this.onSignupManually,
    required this.onLogin,
  });

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
    return Container(
      key: const ValueKey('auth'),
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
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: onLogin,
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
                        // This Spacer pushes everything down
                        const Spacer(),
                        const Text(
                          'Get started with\nConverf',
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
                          'Build world-class infrastructure across Africa',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
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
                        const SizedBox(height: 24),
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
                            onPressed: onSignupManually,
                            child: const Text(
                              'Signup Manually',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
