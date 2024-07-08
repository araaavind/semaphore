import 'package:app/core/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = _newTextTheme().apply(
    displayColor: AppColorScheme.lightColorScheme.onSurface,
    bodyColor: AppColorScheme.lightColorScheme.onSurface,
  );

  static TextTheme darkTextTheme = _newTextTheme().apply(
    displayColor: AppColorScheme.darkColorScheme.onSurface,
    bodyColor: AppColorScheme.darkColorScheme.onSurface,
  );
}

TextTheme _newTextTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(),
    bodyMedium: TextStyle(),
    bodySmall: TextStyle(),
    displayLarge: TextStyle(),
    displayMedium: TextStyle(),
    displaySmall: TextStyle(),
    headlineLarge: TextStyle(),
    headlineMedium: TextStyle(),
    headlineSmall: TextStyle(),
    titleLarge: TextStyle(),
    titleMedium: TextStyle(),
    titleSmall: TextStyle(),
    labelLarge: TextStyle(),
    labelMedium: TextStyle(),
    labelSmall: TextStyle(),
  );
}
