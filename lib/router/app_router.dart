import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/product_owner/product_owner_dashboard_screen.dart';
import '../screens/contractor/contractor_dashboard_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/models/auth_response.dart';

final routerRefreshProvider = Provider((ref) => RouterRefreshNotifier(ref));

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      // If we are loading, don't redirect yet
      if (authState.isLoading) return null;

      final user = authState.value;
      final isAuthenticated = user != null && user.status == true;
      final isLoggingIn = state.matchedLocation == '/onboarding' || state.matchedLocation == '/';

      if (!isAuthenticated) {
        // If not authenticated and not on splash or onboarding, go to onboarding
        if (!isLoggingIn) return '/onboarding';
        return null;
      }

      // If authenticated and on onboarding/splash, go to dashboard
      if (isLoggingIn) {
        return authState.value?.role == UserRole.projectOwner ? '/owner-dashboard' : '/contractor-dashboard';
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
