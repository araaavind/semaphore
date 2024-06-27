import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SemaphoreApp());
}

class SemaphoreApp extends StatelessWidget {
  const SemaphoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      dark: ThemeData.dark(),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Semaphore',
        theme: theme,
        darkTheme: darkTheme,
        home: const SignupPage(),
      ),
    );
  }
}
