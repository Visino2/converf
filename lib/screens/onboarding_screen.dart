import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/onboarding/onboarding_splash_step.dart';
import 'widgets/onboarding/onboarding_role_step.dart';
import 'widgets/onboarding/onboarding_auth_step.dart';
import 'widgets/onboarding/onboarding_signup_step.dart';
import 'widgets/onboarding/onboarding_login_step.dart';
import 'widgets/onboarding/contractor_signup/contractor_signup_main.dart';
import 'widgets/onboarding/welcome_project_owner_step.dart';
import 'widgets/onboarding/welcome_contractor_step.dart';
import 'widgets/onboarding/onboarding_forgot_password_step.dart';
import 'widgets/onboarding/onboarding_reset_password_step.dart';
import 'widgets/onboarding/onboarding_accept_invitation_step.dart';
import '../features/auth/models/auth_response.dart';
import '../features/auth/providers/auth_provider.dart';

enum OnboardingStep {
  splash,
  role,
  auth,
  login,
  signup,
  welcome,
  forgotPassword,
  resetPassword,
  acceptInvitation,
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.initialStep = OnboardingStep.splash});

  final OnboardingStep initialStep;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late OnboardingStep _step;
  String? _selectedRole;
  String? _resetEmail;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;

    if (_step == OnboardingStep.splash) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _step = OnboardingStep.role);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case OnboardingStep.splash:
        return const OnboardingSplashStep();
      case OnboardingStep.role:
        return OnboardingRoleStep(
          onRoleSelected: (role) {
            _selectedRole = role;
            setState(() => _step = OnboardingStep.auth);
          },
          onLogin: () => setState(() => _step = OnboardingStep.login),
        );
      case OnboardingStep.auth:
        return OnboardingAuthStep(
          selectedRole: _selectedRole,
          onSignupManually: () {
            setState(() => _step = OnboardingStep.signup);
          },
          onLogin: () => setState(() => _step = OnboardingStep.login),
        );
      case OnboardingStep.login:
        return OnboardingLoginStep(
          selectedRole: _selectedRole,
          onSignup: () => setState(() => _step = OnboardingStep.auth),
          onForgotPassword: () =>
              setState(() => _step = OnboardingStep.forgotPassword),
          onBack: () => setState(() => _step = OnboardingStep.auth),
        );
      case OnboardingStep.signup:
        if (_selectedRole == 'contractor') {
          return OnboardingContractorSignupStep(
            onSignupSubmit: () {
              setState(() => _step = OnboardingStep.welcome);
            },
            onBack: () {
              setState(() => _step = OnboardingStep.auth);
            },
          );
        }
        return OnboardingSignupStep(
          onSignupSubmit: () {
            setState(() => _step = OnboardingStep.welcome);
          },
          onBack: () {
            setState(() => _step = OnboardingStep.auth);
          },
          onLogin: () => setState(() => _step = OnboardingStep.login),
        );
      case OnboardingStep.welcome:
        final authState = ref.read(authProvider);
        final authRole = authState.value?.role;
        final effectiveRole = switch (authRole) {
          UserRole.projectOwner => 'project_owner',
          UserRole.contractor => 'contractor',
          _ => _selectedRole,
        };

        if (effectiveRole == 'project_owner') {
          return OnboardingWelcomeProjectOwnerStep(
            onCompleted: () => context.go('/owner-dashboard'),
          );
        } else {
          return OnboardingWelcomeContractorStep(
            onCompleted: () => context.go('/contractor-dashboard'),
          );
        }
      case OnboardingStep.forgotPassword:
        return OnboardingForgotPasswordStep(
          onBack: () => setState(() => _step = OnboardingStep.login),
          onResetPassword: (email) => setState(() {
            _resetEmail = email;
            _step = OnboardingStep.resetPassword;
          }),
        );
      case OnboardingStep.resetPassword:
        return OnboardingResetPasswordStep(
          onBackToLogin: () => setState(() => _step = OnboardingStep.login),
          initialEmail: _resetEmail,
        );
      case OnboardingStep.acceptInvitation:
        return OnboardingAcceptInvitationStep(
          token: '',
          onAccepted: () => setState(() => _step = OnboardingStep.login),
          onBackToLogin: () => setState(() => _step = OnboardingStep.login),
        );
    }
  }
}
