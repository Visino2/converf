import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ConverfApp(),
    ),
  );
}

class ConverfApp extends ConsumerWidget {
  const ConverfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Converf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF276572)),
        scaffoldBackgroundColor: const Color(0xFF276572),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
