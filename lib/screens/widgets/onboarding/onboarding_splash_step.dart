import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              child: SvgPicture.asset('assets/images/logo.svg', height: 48),
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
