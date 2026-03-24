import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP STARTING ---');
  
  FlutterError.onError = (details) {
    debugPrint('--- FLUTTER ERROR ---');
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack?.toString());
  };

  runApp(
    const ProviderScope(
      child: ConverfApp(),
    ),
  );
}

class ConverfApp extends ConsumerWidget {
  const ConverfApp({super.key});

  static final _theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF276572)),
    scaffoldBackgroundColor: const Color(0xFF276572),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Converf',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      routerConfig: router,
    );
  }
}
