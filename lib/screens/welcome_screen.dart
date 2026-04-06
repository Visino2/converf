import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/models/auth_response.dart';
import '../features/auth/providers/auth_provider.dart';
import '../screens/widgets/onboarding/welcome_contractor_step.dart';
import '../screens/widgets/onboarding/welcome_project_owner_step.dart';

/// A standalone welcome screen shown only once per user after email verification.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final role = user?.role ?? UserRole.unknown;

    Future<void> completeAndGo() async {
      final userId = user?.data?.user['id']?.toString() ?? '';
      if (userId.isNotEmpty) {
        await ref.read(welcomeSeenActionProvider).markAsSeen(userId);
      }
      if (context.mounted) {
        final dashboardRoute = role == UserRole.projectOwner
            ? '/owner-dashboard'
            : '/contractor-dashboard';
        context.go(dashboardRoute);
      }
    }

    if (role == UserRole.projectOwner) {
      return OnboardingWelcomeProjectOwnerStep(onCompleted: completeAndGo);
    }
    // Default to contractor styling for unknown role to avoid blocking navigation.
    return OnboardingWelcomeContractorStep(onCompleted: completeAndGo);
  }
}
