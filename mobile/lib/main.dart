import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TakeTwoApp()));
}

class TakeTwoApp extends ConsumerWidget {
  const TakeTwoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Take Two',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
          brightness: Brightness.light,
          surface: const Color.fromARGB(255, 222, 230, 238),
          surfaceContainer: const Color.fromARGB(255, 222, 230, 238),
        ),
      ),

      // 2. DARK THEME CONFIGURATION
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
          surface: Colors.black,
          surfaceTint: Colors.black,
          surfaceContainer: Colors.black,
          surfaceContainerHigh: const Color.fromARGB(255, 23, 43, 61),
          onPrimaryContainer: Colors.white,
        ),
        appBarTheme: const AppBarTheme(toolbarHeight: 50),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 231, 44, 53),
            foregroundColor: Colors.white,
          ),
        ),
      ),

      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
