import 'package:flutter/material.dart';

class OnboardingSplashStep extends StatelessWidget {
  const OnboardingSplashStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('splash'),
      color: const Color(0xFF276572),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset('assets/images/logo.png', height: 48),
            ),
            const SizedBox(width: 16),
            const Text(
              'Converf',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
