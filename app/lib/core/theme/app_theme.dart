import 'package:app/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}

extension ThemeDataExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  AppColorsExtension get lightAppColors =>
      extension<AppColorsExtension>() ?? AppTheme._lightAppColors;
  AppColorsExtension get darkAppColors =>
      extension<AppColorsExtension>() ?? AppTheme._darkAppColors;
}

class AppTheme {
  static final light = ThemeData.light().copyWith(
    appBarTheme: const AppBarTheme(),
    extensions: [
      _lightAppColors,
    ],
  );

  static final _lightAppColors = AppColorsExtension(
    primary: const Color.fromRGBO(98, 0, 238, 1),
    onPrimary: Colors.white,
    secondary: const Color.fromRGBO(3, 218, 198, 1),
    onSecondary: Colors.black,
    error: const Color.fromRGBO(176, 0, 32, 1),
    onError: Colors.white,
    surface: const Color.fromRGBO(250, 250, 255, 1),
    onSurface: Colors.black,
  );

  static final dark = ThemeData.dark().copyWith(
    extensions: [
      _darkAppColors,
    ],
  );

  static final _darkAppColors = AppColorsExtension(
    primary: const Color.fromRGBO(187, 134, 252, 1),
    onPrimary: Colors.black,
    secondary: const Color.fromRGBO(3, 218, 198, 1),
    onSecondary: Colors.black,
    error: const Color.fromRGBO(207, 102, 121, 1),
    onError: Colors.black,
    surface: const Color.fromRGBO(10, 4, 10, 1),
    onSurface: Colors.white,
  );
}
