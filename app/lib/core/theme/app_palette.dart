import 'package:flutter/material.dart';

abstract class AppPalette {
  // Red
  static const primary = Color(0xFF7F5A83);
  static const primaryDark = Color(0xFF644467);
  static const onPrimary = Colors.white;
  static const onPrimaryDark = Colors.white;
  static const secondary = Color(0xFFE6C3ED);
  static const secondaryDark = Color(0xFFC092C9);
  static const onSecondary = Colors.black;
  static const onSecondaryDark = Colors.black;
  static const tertiary = Color(0xFFE4FF6B);
  static const tertiaryDark = Color(0xFFC9DF68);
  static const onTertiary = Colors.black;
  static const onTertiaryDark = Colors.black;
  static const surface = Color(0xFFFAFAFF);
  static const surfaceDark = Color(0xFF080808);
  static const onSurface = Colors.black;
  static const onSurfaceDark = Colors.white;
  static const error = Color(0xFFFF0035);
  static const errorDark = Color(0xFFFF0035);
  static const onError = Colors.white;
  static const onErrorDark = Colors.white;

  // Grey
  static const grey = _GreyColors();
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
