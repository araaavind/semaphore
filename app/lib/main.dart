import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';

import 'core/theme/theme.dart';

void main() {
  runApp(const SemaphoreApp());
}

class SemaphoreApp extends StatelessWidget {
  const SemaphoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.light,
      dark: AppTheme.dark,
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
