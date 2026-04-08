import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/auth/session_manager.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingWelcomeProjectOwnerStep extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;
  const OnboardingWelcomeProjectOwnerStep({super.key, this.onCompleted});

  @override
  ConsumerState<OnboardingWelcomeProjectOwnerStep> createState() =>
      _OnboardingWelcomeProjectOwnerStepState();
}

class _OnboardingWelcomeProjectOwnerStepState
    extends ConsumerState<OnboardingWelcomeProjectOwnerStep> {
  static const _redirectDelay = Duration(seconds: 3);

  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(_redirectDelay, _complete);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  Future<void> _complete() async {
    final router = GoRouter.of(context);
    if (!context.mounted) return;
    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }

    final sessionManager = ref.read(sessionManagerProvider);
    final user = await sessionManager.getUser();
    final userId = user?['id']?.toString() ?? '';
    if (userId.isNotEmpty) {
      await sessionManager.setWelcomeSeen(userId);
    }
    if (!context.mounted) return;
    router.go('/owner-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('welcome_project_owner'),
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/frame-1.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withValues(alpha: 0.4),
              colorBlendMode: BlendMode.darken,
            ),
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
                    const Color(0xFFF25C19).withValues(alpha: 0.9),
                    const Color(0xFFF25C19).withValues(alpha: 0.5),
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
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.4),
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
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
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
