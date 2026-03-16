import 'package:flutter/material.dart';

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

enum OnboardingStep { splash, role, auth, login, signup, welcome, forgotPassword, resetPassword, acceptInvitation }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingStep _step = OnboardingStep.splash;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    // 3000ms delay before transitioning to Role Selection
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _step = OnboardingStep.role);
      }
    });
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
          onSignupManually: () {
            setState(() => _step = OnboardingStep.signup);
          },
          onLogin: () => setState(() => _step = OnboardingStep.login),
        );
      case OnboardingStep.login:
        return OnboardingLoginStep(
          onSignup: () => setState(() => _step = OnboardingStep.auth),
          onForgotPassword: () => setState(() => _step = OnboardingStep.forgotPassword),
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
        if (_selectedRole == 'project_owner') {
          return const OnboardingWelcomeProjectOwnerStep();
        } else {
          return const OnboardingWelcomeContractorStep();
        }
      case OnboardingStep.forgotPassword:
        return OnboardingForgotPasswordStep(
          onBack: () => setState(() => _step = OnboardingStep.login),
          onResetPassword: () => setState(() => _step = OnboardingStep.resetPassword),
        );
      case OnboardingStep.resetPassword:
        return OnboardingResetPasswordStep(
          onBackToLogin: () => setState(() => _step = OnboardingStep.login),
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
