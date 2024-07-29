import 'package:flutter/material.dart';

abstract class AppPalette {
  // Color Scheme Colors
  // Lights
  static const primary = Color.fromARGB(255, 75, 2, 52);
  static const onPrimary = Color.fromARGB(255, 255, 251, 245);
  static const primaryContainer = Color.fromARGB(255, 254, 215, 210);
  static const onPrimaryContainer = Color.fromARGB(255, 67, 13, 32);
  static const secondary = Color.fromARGB(255, 154, 63, 33);
  static const onSecondary = Color.fromARGB(255, 255, 247, 238);
  static const secondaryContainer = Color.fromARGB(255, 241, 191, 175);
  static const onSecondaryContainer = Color.fromARGB(255, 154, 63, 33);
  static const tertiary = Color.fromARGB(255, 40, 75, 2);
  static const onTertiary = Color.fromARGB(255, 254, 255, 239);
  static const tertiaryContainer = Color.fromARGB(255, 213, 237, 186);
  static const onTertiaryContainer = Color.fromARGB(255, 40, 75, 2);
  static const surface = Color.fromARGB(255, 253, 253, 253);
  static const onSurface = Color.fromARGB(255, 41, 20, 23);
  static const surfaceContainerLowest = Color.fromARGB(255, 247, 242, 244);
  static const surfaceContainerLow = Color.fromARGB(255, 247, 237, 242);
  static const surfaceContainer = Color.fromARGB(255, 241, 228, 235);
  static const surfaceContainerHigh = Color.fromARGB(255, 234, 222, 228);
  static const surfaceContainerHighest = Color.fromARGB(255, 224, 212, 218);
  static const error = Color.fromARGB(255, 214, 22, 60);
  static const onError = Colors.white;
  static const disabledPrimary = Color.fromARGB(255, 108, 103, 106);
  static const outline = Color.fromARGB(255, 212, 212, 212);
  // Darks
  static const primaryDark = Color.fromARGB(255, 248, 180, 175);
  static const onPrimaryDark = Color.fromARGB(255, 19, 1, 4);
  static const primaryContainerDark = Color.fromARGB(255, 67, 13, 32);
  static const onPrimaryContainerDark = Color.fromARGB(255, 254, 215, 210);
  static const secondaryDark = Color.fromARGB(255, 254, 209, 150);
  static const onSecondaryDark = Color.fromARGB(255, 24, 10, 6);
  static const secondaryContainerDark = Color.fromARGB(255, 100, 61, 11);
  static const onSecondaryContainerDark = Color.fromARGB(255, 254, 209, 150);
  static const tertiaryDark = Color.fromARGB(255, 225, 248, 175);
  static const onTertiaryDark = Color.fromARGB(255, 14, 20, 8);
  static const tertiaryContainerDark = Color.fromARGB(255, 59, 63, 4);
  static const onTertiaryContainerDark = Color.fromARGB(255, 243, 248, 175);
  static const surfaceDark = Color.fromARGB(255, 0, 0, 0);
  static const onSurfaceDark = Color.fromARGB(255, 246, 238, 227);
  static const surfaceContainerLowestDark = Color.fromARGB(255, 23, 18, 17);
  static const surfaceContainerLowDark = Color.fromARGB(255, 32, 25, 24);
  static const surfaceContainerDark = Color.fromARGB(255, 36, 28, 27);
  static const surfaceContainerHighDark = Color.fromARGB(255, 44, 33, 31);
  static const surfaceContainerHighestDark = Color.fromARGB(255, 49, 36, 35);
  static const errorDark = Color.fromARGB(255, 153, 34, 58);
  static const onErrorDark = Colors.white;
  static const disabledPrimaryDark = Color.fromARGB(255, 190, 190, 190);
  static const outlineDark = Color.fromARGB(255, 61, 61, 61);

  // Extension colors
  static const networkOnlineSnackbarContainer = Color.fromARGB(255, 9, 45, 15);
  static const networkOnlineSnackbarOnContainer =
      Color.fromARGB(255, 233, 255, 228);
  static const networkOfflineSnackbarContainer =
      Color.fromARGB(255, 61, 18, 18);
  static const networkOfflineSnackbarOnContainer =
      Color.fromARGB(255, 252, 204, 192);
  static const networkOnlineSnackbarContainerDark =
      Color.fromARGB(255, 233, 255, 228);
  static const networkOnlineSnackbarOnContainerDark =
      Color.fromARGB(255, 9, 45, 15);
  static const networkOfflineSnackbarContainerDark =
      Color.fromARGB(255, 252, 204, 192);
  static const networkOfflineSnackbarOnContainerDark =
      Color.fromARGB(255, 61, 18, 18);

  // Green
  static const green = Color.fromARGB(255, 140, 181, 94);

  // Grey
  static const grey = _GreyColors();

  static const transparent = Colors.transparent;
}

/// Alternative way to group colors in the palette.
///
/// The downside is that they can't be
/// used as constructor default values,
/// since they are not constants.
///
/// Usage example: `AppPalette.grey.grey50`.
class _GreyColors {
  const _GreyColors();

  final grey50 = const Color(0xFFFAFAFA);
  final grey100 = const Color(0xFFF5F5F5);
}
