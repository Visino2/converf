import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/auth/session_manager.dart';
import '../../product_owner/widgets/dashboard/more/billing/utils/billing_formatters.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingWelcomeContractorStep extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;
  const OnboardingWelcomeContractorStep({super.key, this.onCompleted});

  @override
  ConsumerState<OnboardingWelcomeContractorStep> createState() =>
      _OnboardingWelcomeContractorStepState();
}

class _OnboardingWelcomeContractorStepState
    extends ConsumerState<OnboardingWelcomeContractorStep> {
  static const _redirectDelay = Duration(milliseconds: 1500);

  Timer? _redirectTimer;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _redirectTimer = Timer(_redirectDelay, _complete);
  }

  Future<void> _loadUser() async {
    final sessionManager = ref.read(sessionManagerProvider);
    final user = await sessionManager.getUser();
    if (user != null && mounted) {
      setState(() {
        _displayName = user['company_name']?.toString() ?? user['first_name']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  Future<void> _complete() async {
    final router = GoRouter.of(context);
    if (!context.mounted) return;

    // 1. Mark welcome as seen immediately to prevent onboarding loops
    final sessionManager = ref.read(sessionManagerProvider);
    final user = await sessionManager.getUser();
    final userId = user?['id']?.toString() ?? '';
    if (userId.isNotEmpty) {
      await sessionManager.setWelcomeSeen(userId);
    }

    // 2. Execute completion callback or default redirect
    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }

    if (!context.mounted) return;
    router.go('/contractor-dashboard');
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
            child: Image.asset(
              'assets/images/frame-2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withValues(alpha: 0.3),
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
                    const Color(0xFF309DAA).withValues(alpha: 0.1),
                    const Color(0xFF386D76).withValues(alpha: 0.5),
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
                Text(
                  _displayName.isNotEmpty
                      ? 'Welcome\n${_displayName.toTitleCase()}\nto Converf'
                      : 'Welcome to\nConverf as\nContractor',
                  style: const TextStyle(
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
