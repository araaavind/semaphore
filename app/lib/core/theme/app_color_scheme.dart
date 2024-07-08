import 'package:app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

class AppColorScheme {
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
