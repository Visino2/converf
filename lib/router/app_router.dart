import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/product_owner/product_owner_dashboard_screen.dart';
import '../screens/contractor/contractor_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/owner-dashboard',
        name: 'owner-dashboard',
        builder: (context, state) => const ProductOwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/contractor-dashboard',
        name: 'contractor-dashboard',
        builder: (context, state) => const ContractorDashboardScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeOut).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
});
