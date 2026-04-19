import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/ui/app_colors.dart';
import 'core/ui/app_scaffold_messenger.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/email_verification_provider.dart';
import 'features/auth/services/auth_app_links_service.dart';
import 'features/notifications/services/firebase_messaging_service.dart';
import 'features/notifications/services/notification_lifecycle_service.dart';
import 'router/app_router.dart';
import 'core/auth/session_timeout_wrapper.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/shared_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP STARTING ---');

  final sharedPreferences = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('--- FIREBASE INIT ERROR ---');
    debugPrint(e.toString());
  }

  FlutterError.onError = (details) {
    debugPrint('--- FLUTTER ERROR ---');
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack?.toString());
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ConverfApp(),
    ),
  );
}

class ConverfApp extends ConsumerWidget {
  const ConverfApp({super.key});

  static final _theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
    scaffoldBackgroundColor: AppColors.appBackground,
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);
    final verificationState = ref.watch(emailVerificationStatusProvider);

    unawaited(ref.read(authAppLinksServiceProvider).initialize(router));
    unawaited(ref.read(firebaseMessagingServiceProvider).initialize(router));
    unawaited(
      ref
          .read(notificationLifecycleProvider)
          .syncForAuthState(authState, verificationState: verificationState),
    );

    return MaterialApp.router(
      title: 'Converf',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) {
        return SessionTimeoutWrapper(
          timeoutDuration: const Duration(minutes: 15),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
