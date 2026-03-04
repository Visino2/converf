import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class OnboardingWelcomeProjectOwnerStep extends StatefulWidget {
  const OnboardingWelcomeProjectOwnerStep({super.key});

  @override
  State<OnboardingWelcomeProjectOwnerStep> createState() =>
      _OnboardingWelcomeProjectOwnerStepState();
}

class _OnboardingWelcomeProjectOwnerStepState
    extends State<OnboardingWelcomeProjectOwnerStep> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('welcome_project_owner'),
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/frame.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          // Top orange gradient overlay for Project Owner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF25C19).withOpacity(0.9),
                    const Color(0xFFF25C19).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Transform.rotate(
                    angle: -math.pi / 2,
                    child: const CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 4.0,
                      color: Color(0xFFF25C19),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to\nConverf as project\nowner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
