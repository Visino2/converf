import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ui/app_navigation.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/product_owner/product_owner_dashboard_screen.dart';
import '../screens/contractor/contractor_dashboard_screen.dart';
import '../screens/widgets/onboarding/onboarding_accept_invitation_step.dart';
import '../screens/widgets/onboarding/onboarding_reset_password_step.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/providers/email_verification_provider.dart';
import '../features/auth/models/auth_response.dart';
import '../features/auth/models/email_verification_status.dart';
import '../features/auth/utils/auth_flow.dart';
import '../screens/widgets/onboarding/onboarding_verify_email_step.dart';
import '../screens/welcome_screen.dart';
import '../screens/product_owner/widgets/dashboard/notifications/notifications_screen.dart';
import '../screens/product_owner/widgets/dashboard/messages/project_inbox_screen.dart';
import '../screens/product_owner/widgets/dashboard/projects/project_details_screen.dart';
import '../screens/contractor/projects/widgets/tools/contractor_notifications_screen.dart';
import '../screens/contractor/projects/contractor_project_details_screen.dart';

final routerRefreshProvider = Provider((ref) => RouterRefreshNotifier(ref));

class RouterRefreshNotifier extends ChangeNotifier {
  bool _refreshScheduled = false;
  bool _disposed = false;

  RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => _scheduleRefresh());
    ref.listen(emailVerificationStatusProvider, (_, _) => _scheduleRefresh());
    ref.listen(welcomeSeenRefreshProvider, (_, _) => _scheduleRefresh());
  }

  void _scheduleRefresh() {
    if (_refreshScheduled || _disposed) {
      return;
    }
    _refreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        _refreshScheduled = false;
        if (_disposed) {
          return;
        }
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: onboardingRoute,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final verificationState = ref.read(emailVerificationStatusProvider);
      final locationPath = state.uri.path;

      final user = authState.value;
      final isAuthenticated = isAuthenticatedResponse(user);
      final isAuthRoute = isRootAuthPath(locationPath);
      final isPasswordReset = locationPath == '/auth/reset-password';
      final isAcceptInvitationRoute = isAcceptInvitationPath(locationPath);
      final isVerifyEmailRoute = isVerifyEmailPath(locationPath);
      final dashboardRoute = dashboardRouteForRole(
        user?.role ?? UserRole.unknown,
      );

      if (!isAuthenticated) {
        // While loading initial auth state, don't force redirects
        if (authState.isLoading && authState.value == null) {
          return null;
        }

        if (locationPath == splashRoute) {
          return onboardingRoute;
        }
        if (isVerifyEmailRoute) {
          return onboardingLocation(login: true);
        }
        if (!isAuthRoute && !isPasswordReset && !isAcceptInvitationRoute) {
          return onboardingLocation(login: true);
        }
        return null;
      }

      if (dashboardRoute == null) {
        return onboardingLocation(login: true);
      }

      if (verificationState.isLoading) {
        // Stay on current route while checking verification status to prevent flickering
        return null;
      }

      final verificationStatus =
          verificationState.asData?.value ?? EmailVerificationStatus.unknown;

      // Verification Gate: only force verification if EXPLICITLY unverified.
      // We allow 'unknown' to proceed to the dashboard, relying on the dashboard
      // API calls to fail if the user is truly blocked by the backend.
      if (verificationStatus == EmailVerificationStatus.unverified) {
        return isVerifyEmailRoute
            ? null
            : verifyEmailLocation(email: user?.user['email']?.toString());
      }

      // New-user welcome gate: after verification, show welcome once per user.
      final rawUserId = user?.data?.user['id'];
      final userId = rawUserId == null ? '' : rawUserId.toString();
      if (userId.isNotEmpty) {
        final hasSeen = ref.read(welcomeSeenProvider(userId));
        if (!hasSeen && locationPath != '/welcome') return '/welcome';
        if (hasSeen && locationPath == '/welcome') return dashboardRoute;
      }

      if (isOwnerDashboardPath(locationPath) &&
          user?.role != UserRole.projectOwner) {
        return dashboardRoute;
      }

      if (isContractorDashboardPath(locationPath) &&
          user?.role != UserRole.contractor) {
        return dashboardRoute;
      }

      if (isAuthRoute || isVerifyEmailRoute) {
        return dashboardRoute;
      }

      if (isAcceptInvitationRoute) {
        return dashboardRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/owner-dashboard',
        name: 'owner-dashboard',
        builder: (context, state) => ProductOwnerDashboardScreen(
          initialIndex: _ownerDashboardTabIndex(
            state.uri.queryParameters['tab'],
          ),
        ),
      ),
      GoRoute(
        path: '/contractor-dashboard',
        name: 'contractor-dashboard',
        builder: (context, state) => ContractorDashboardScreen(
          initialIndex: _contractorDashboardTabIndex(
            state.uri.queryParameters['tab'],
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final initialStep = switch (mode) {
            'login' => OnboardingStep.login,
            _ => OnboardingStep.splash,
          };
          return CustomTransitionPage(
            key: const ValueKey('onboarding_page'),
            child: OnboardingScreen(initialStep: initialStep),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeOut,
                    ).animate(animation),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/accept-invitation',
        name: 'accept-invitation',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return OnboardingAcceptInvitationStep(
            token: token,
            onAccepted: () => context.go(onboardingLocation(login: true)),
            onBackToLogin: () => context.go(onboardingLocation(login: true)),
          );
        },
      ),
      GoRoute(
        path: '/auth/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final email = state.uri.queryParameters['email'];
          return Scaffold(
            body: OnboardingResetPasswordStep(
              initialEmail: email,
              initialToken: token,
              onBackToLogin: () => context.go(onboardingLocation(login: true)),
            ),
          );
        },
      ),
      GoRoute(
        path: '/auth/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          return OnboardingVerifyEmailStep(
            email: state.uri.queryParameters['email'],
            autoResend: state.uri.queryParameters['auto_resend'] == '1',
            verifyUrl: state.uri.queryParameters['verify_url'],
            verificationId: state.uri.queryParameters['id'],
            verificationHash: state.uri.queryParameters['hash'],
            verificationQueryParameters: state.uri.queryParameters,
          );
        },
      ),
      GoRoute(
        path: '/auth/email/verify/:id/:hash',
        name: 'verify-email-link',
        builder: (context, state) {
          return OnboardingVerifyEmailStep(
            email: state.uri.queryParameters['email'],
            autoResend: state.uri.queryParameters['auto_resend'] == '1',
            verifyUrl: state.uri.queryParameters['verify_url'],
            verificationId: state.pathParameters['id'],
            verificationHash: state.pathParameters['hash'],
            verificationQueryParameters: state.uri.queryParameters,
          );
        },
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/contractor-notifications',
        name: 'contractor-notifications',
        builder: (context, state) => const ContractorNotificationsScreen(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const ProjectInboxScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId',
        name: 'project-details',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/contractor-projects/:projectId',
        name: 'contractor-project-details',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ContractorProjectDetailsScreen(projectId: projectId);
        },
      ),
    ],
  );
});

int _ownerDashboardTabIndex(String? tab) {
  switch (tab?.trim().toLowerCase()) {
    case 'projects':
      return 1;
    case 'team':
      return 2;
    case 'more':
      return 3;
    case 'dashboard':
    default:
      return 0;
  }
}

int _contractorDashboardTabIndex(String? tab) {
  switch (tab?.trim().toLowerCase()) {
    case 'projects':
      return 1;
    case 'marketplace':
      return 2;
    case 'tools':
      return 3;
    case 'dashboard':
    default:
      return 0;
  }
}
