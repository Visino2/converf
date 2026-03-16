import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingWelcomeContractorStep extends StatefulWidget {
  const OnboardingWelcomeContractorStep({super.key});

  @override
  State<OnboardingWelcomeContractorStep> createState() =>
      _OnboardingWelcomeContractorStepState();
}

class _OnboardingWelcomeContractorStepState
    extends State<OnboardingWelcomeContractorStep> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.go('/contractor-dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('welcome_contractor'),
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/frame-2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
       
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
                    const Color(0xFF386D76).withOpacity(0.9),
                    const Color(0xFF386D76).withOpacity(0.5),
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
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: -math.pi / 2,
                        child: const CircularProgressIndicator(
                          value: 0.25,
                          strokeWidth: 4.0,
                          color: Color(0xFFF25C19),
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/images/check.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFF25C19),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to\nConverf as\nContractor',
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
