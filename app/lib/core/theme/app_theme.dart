import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}

class AppTheme {
  static _border([Color color = AppPalette.outline]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadius),
      );

  static final light = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.surface,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(UIConstants.elementPadding),
      border: _border(lightColorScheme.outline),
      enabledBorder: _border(lightColorScheme.outline),
      focusedBorder: _border(lightColorScheme.primary),
      errorBorder: _border(lightColorScheme.error),
    ),
  );
  static final dark = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(UIConstants.elementPadding),
      border: _border(darkColorScheme.outline),
      enabledBorder: _border(darkColorScheme.outline),
      focusedBorder: _border(darkColorScheme.primary),
      errorBorder: _border(darkColorScheme.error),
    ),
  );

  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.primary,
    onPrimary: AppPalette.onPrimary,
    secondary: AppPalette.secondary,
    onSecondary: AppPalette.onSecondary,
    tertiary: AppPalette.tertiary,
    onTertiary: AppPalette.onTertiary,
    error: AppPalette.error,
    onError: AppPalette.onError,
    surface: AppPalette.surface,
    onSurface: AppPalette.onSurface,
    surfaceContainer: AppPalette.surfaceContainer,
    surfaceContainerLow: AppPalette.surfaceContainerLow,
    surfaceContainerLowest: AppPalette.surfaceContainerLowest,
    surfaceContainerHigh: AppPalette.surfaceContainerHigh,
    surfaceContainerHighest: AppPalette.surfaceContainerHighest,
    outline: AppPalette.outline,
  );

  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.primaryDark,
    onPrimary: AppPalette.onPrimaryDark,
    secondary: AppPalette.secondaryDark,
    onSecondary: AppPalette.onSecondaryDark,
    tertiary: AppPalette.tertiaryDark,
    onTertiary: AppPalette.onTertiaryDark,
    error: AppPalette.errorDark,
    onError: AppPalette.onErrorDark,
    surface: AppPalette.surfaceDark,
    onSurface: AppPalette.onSurfaceDark,
    surfaceContainer: AppPalette.surfaceContainerDark,
    surfaceContainerLow: AppPalette.surfaceContainerLowDark,
    surfaceContainerLowest: AppPalette.surfaceContainerLowestDark,
    surfaceContainerHigh: AppPalette.surfaceContainerHighDark,
    surfaceContainerHighest: AppPalette.surfaceContainerHighestDark,
    outline: AppPalette.outlineDark,
  );
}
