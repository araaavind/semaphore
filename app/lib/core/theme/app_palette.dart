import 'package:flutter/material.dart';

abstract class AppPalette {
  static const primary = Color.fromARGB(255, 75, 2, 52);
  static const primaryDark = Color.fromARGB(255, 248, 180, 175);
  static const onPrimary = Color.fromARGB(255, 255, 251, 245);
  static const onPrimaryDark = Color.fromARGB(255, 19, 1, 4);
  static const secondary = Color.fromARGB(255, 154, 63, 33);
  static const secondaryDark = Color.fromARGB(255, 248, 216, 175);
  static const onSecondary = Color.fromARGB(255, 255, 247, 238);
  static const onSecondaryDark = Color.fromARGB(255, 24, 10, 6);
  static const tertiary = Color.fromARGB(255, 40, 75, 2);
  static const tertiaryDark = Color.fromARGB(255, 243, 248, 175);
  static const onTertiary = Color.fromARGB(255, 254, 255, 239);
  static const onTertiaryDark = Color.fromARGB(255, 14, 20, 8);
  static const surface = Color.fromARGB(255, 253, 253, 253);
  static const surfaceDark = Color.fromARGB(255, 8, 8, 8);
  static const onSurface = Color.fromARGB(255, 41, 20, 23);
  static const onSurfaceDark = Color.fromARGB(255, 246, 238, 227);
  static const error = Color.fromARGB(255, 214, 22, 60);
  static const errorDark = Color.fromARGB(255, 153, 34, 58);
  static const onError = Colors.white;
  static const onErrorDark = Colors.white;
  // Need to finalize colors for properties below
  static const surfaceContainerLowest = Color(0xFFE6FDFF);
  static const surfaceContainerLowestDark = Color(0xFF25364C);
  static const surfaceContainerLow = Color(0xFFDAFDFF);
  static const surfaceContainerLowDark = Color(0xFF2F445E);
  static const surfaceContainer = Color(0xFFCCFBFE);
  static const surfaceContainerDark = Color(0xFF3A5372);
  static const surfaceContainerHigh = Color(0xFFC1F9FD);
  static const surfaceContainerHighDark = Color(0xFF446083);
  static const surfaceContainerHighest = Color(0xFFAFFAFF);
  static const surfaceContainerHighestDark = Color(0xFF5275A0);
  static const outline = Color(0xFFABABAB);
  static const outlineDark = Color(0xFF3D3D3D);

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
