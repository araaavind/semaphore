import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}

class AppTheme {
  static final light = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    colorScheme: lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.surface,
    ),
    scaffoldBackgroundColor: lightColorScheme.surface,
  );
  static final dark = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    colorScheme: darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
    ),
    scaffoldBackgroundColor: darkColorScheme.surface,
  );

  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.primary,
    onPrimary: AppPalette.onPrimary,
    secondary: AppPalette.secondary,
    onSecondary: AppPalette.onSecondary,
    error: AppPalette.error,
    onError: AppPalette.onError,
    surface: AppPalette.surface,
    onSurface: AppPalette.onSurface,
  );

  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.primaryDark,
    onPrimary: AppPalette.onPrimaryDark,
    secondary: AppPalette.secondaryDark,
    onSecondary: AppPalette.onSecondaryDark,
    error: AppPalette.errorDark,
    onError: AppPalette.onErrorDark,
    surface: AppPalette.surfaceDark,
    onSurface: AppPalette.onSurfaceDark,
  );
}
