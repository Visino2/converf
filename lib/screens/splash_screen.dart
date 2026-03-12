import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    // 1500ms delay as requested
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.pushReplacement('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF276572),
      body: Center(
        child: Hero(
          tag: 'logo',
          child: SvgPicture.asset('assets/images/logo.svg',
            width: 100,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.square_rounded,
              color: Colors.orange,
              size: 100,
            ),
          ),
        ),
      ),
    );
  }
}
