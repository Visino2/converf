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
import 'core/cache/hive_cache_service.dart';
import 'core/providers/cache_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== APP STARTING ===');
  debugPrint('[INIT] WidgetsFlutterBinding initialized');

  // Initialize Hive cache
  try {
    await HiveCacheService().init();
    debugPrint('[INIT] Hive cache initialized successfully');
  } catch (e) {
    debugPrint('[ERROR] Hive cache initialization failed: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  debugPrint('[INIT] SharedPreferences loaded');

  try {
    await Firebase.initializeApp();
    debugPrint('[INIT] Firebase initialized');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('[INIT] Firebase messaging background handler registered');
  } catch (e) {
    debugPrint('[ERROR] FIREBASE INIT ERROR: $e');
  }

  FlutterError.onError = (details) {
    debugPrint('=== FLUTTER ERROR ===');
    debugPrint('[ERROR] ${details.exceptionAsString()}');
    debugPrint('[STACK] ${details.stack?.toString()}');
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

class ConverfApp extends ConsumerStatefulWidget {
  const ConverfApp({super.key});

  @override
  ConsumerState<ConverfApp> createState() => _ConverfAppState();
}

class _ConverfAppState extends ConsumerState<ConverfApp> {
  late final ProviderSubscription<dynamic> _authSubscription;
  late final ProviderSubscription<dynamic> _verificationSubscription;
  bool _servicesInitialized = false;
  bool _notificationSyncScheduled = false;

  static final _theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
    scaffoldBackgroundColor: AppColors.appBackground,
    useMaterial3: true,
  );

  @override
  void initState() {
    super.initState();
    _authSubscription = ref.listenManual(
      authProvider,
      (_, __) => _scheduleNotificationLifecycleSync(),
      fireImmediately: true,
    );
    _verificationSubscription = ref.listenManual(
      emailVerificationStatusProvider,
      (_, __) => _scheduleNotificationLifecycleSync(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _servicesInitialized) {
        return;
      }
      _servicesInitialized = true;

      final router = ref.read(routerProvider);
      unawaited(ref.read(authAppLinksServiceProvider).initialize(router));
      unawaited(ref.read(firebaseMessagingServiceProvider).initialize(router));
      ref.read(networkSyncServiceProvider);
    });
  }

  void _scheduleNotificationLifecycleSync() {
    if (_notificationSyncScheduled) {
      return;
    }
    _notificationSyncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationSyncScheduled = false;
      if (!mounted) {
        return;
      }
      _syncNotificationLifecycle();
    });
  }

  void _syncNotificationLifecycle() {
    final authState = ref.read(authProvider);
    final verificationState = ref.read(emailVerificationStatusProvider);
    unawaited(
      ref
          .read(notificationLifecycleProvider)
          .syncForAuthState(authState, verificationState: verificationState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

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

  @override
  void dispose() {
    _authSubscription.close();
    _verificationSubscription.close();
    super.dispose();
  }
}
