import 'package:flutter/material.dart';

// Color Scheme Colors
abstract class AppPalette {
  static HSLColor appBarGradientColor = HSLColor.fromAHSL(0.15, 6, 0.9, 0.5);

  /*
  * Lights
  */
  // brand
  static const brand = Color.fromARGB(255, 95, 14, 27);

  // surface
  static const surface = Color.fromARGB(255, 255, 248, 249);
  static const onSurface = Color.fromARGB(255, 17, 1, 4);
  static const surfaceContainerLowest = Color.fromARGB(255, 250, 231, 234);
  static const surfaceContainerLow = Color.fromARGB(255, 241, 224, 227);
  static const surfaceContainer = Color.fromARGB(255, 236, 218, 221);
  static const surfaceContainerHigh = Color.fromARGB(255, 226, 209, 212);
  static const surfaceContainerHighest = Color.fromARGB(255, 223, 205, 208);

  // primary
  static const primary = Color.fromARGB(255, 95, 14, 27);
  static const onPrimary = Color.fromARGB(255, 255, 248, 249);
  static const primaryContainer = Color.fromARGB(255, 247, 144, 153);
  static const onPrimaryContainer = Color.fromARGB(255, 32, 5, 14);
  static const disabledPrimary = Color.fromARGB(255, 92, 77, 79);

  // secondary
  static const secondary = Color.fromARGB(255, 134, 48, 19);
  static const onSecondary = Color.fromARGB(255, 255, 242, 237);
  static const secondaryContainer = Color.fromARGB(255, 227, 150, 124);
  static const onSecondaryContainer = Color.fromARGB(255, 29, 9, 2);

  // tertiary
  static const tertiary = Color.fromARGB(255, 50, 91, 7);
  static const onTertiary = Color.fromARGB(255, 254, 255, 239);
  static const onTertiaryContainer = Color.fromARGB(255, 172, 215, 126);
  static const tertiaryContainer = Color.fromARGB(255, 13, 23, 1);

  // error
  static const error = Color.fromARGB(255, 214, 22, 60);
  static const onError = Color.fromARGB(255, 255, 235, 235);

  // outline
  static const outline = Color.fromARGB(255, 215, 211, 211);

  static const snackbarSuccessContainer = Color.fromARGB(255, 172, 215, 126);
  static const snackbarSuccessOnContainer = Color.fromARGB(255, 3, 27, 7);
  static const snackbarFailureContainer = Color.fromARGB(255, 231, 110, 110);
  static const snackbarFailureOnContainer = Color.fromARGB(255, 25, 2, 2);
  static const snackbarInfoContainer = Color.fromARGB(255, 26, 20, 21);
  static const snackbarInfoOnContainer = Color.fromARGB(255, 255, 248, 249);
  static const snackbarUtilContainer = Color.fromARGB(255, 26, 20, 21);
  static const snackbarUtilOnContainer = Color.fromARGB(255, 255, 248, 249);
  static const snackbarActionTextColor = Color.fromARGB(255, 247, 144, 153);

  /*
  * Darks
  */

  // brand
  static const brandDark = Color.fromARGB(255, 255, 177, 182);

  // surface
  static const surfaceDark = Color.fromARGB(255, 6, 0, 1);
  static const onSurfaceDark = Color.fromARGB(255, 255, 248, 249);
  static const surfaceContainerLowestDark = Color.fromARGB(255, 21, 16, 16);
  static const surfaceContainerLowDark = Color.fromARGB(255, 29, 21, 21);
  static const surfaceContainerDark = Color.fromARGB(255, 33, 24, 24);
  static const surfaceContainerHighDark = Color.fromARGB(255, 41, 30, 30);
  static const surfaceContainerHighestDark = Color.fromARGB(255, 54, 40, 40);

  // primary
  static const primaryDark = Color.fromARGB(255, 255, 148, 155);
  static const onPrimaryDark = Color.fromARGB(255, 28, 2, 7);
  static const primaryContainerDark = Color.fromARGB(255, 89, 21, 32);
  static const onPrimaryContainerDark = Color.fromARGB(255, 255, 242, 244);
  static const disabledPrimaryDark = Color.fromARGB(255, 222, 203, 204);

  static const secondaryDark = Color.fromARGB(255, 227, 150, 124);
  static const onSecondaryDark = Color.fromARGB(255, 27, 8, 2);
  static const secondaryContainerDark = Color.fromARGB(255, 134, 48, 19);
  static const onSecondaryContainerDark = Color.fromARGB(255, 255, 229, 221);

  // tertiary
  static const tertiaryDark = Color.fromARGB(255, 217, 246, 187);
  static const onTertiaryDark = Color.fromARGB(255, 14, 20, 8);
  static const tertiaryContainerDark = Color.fromARGB(255, 50, 91, 7);
  static const onTertiaryContainerDark = Color.fromARGB(255, 253, 255, 221);

  // error
  static const errorDark = Color.fromARGB(255, 149, 23, 48);
  static const onErrorDark = Color.fromARGB(255, 247, 222, 227);

  // outline
  static const outlineDark = Color.fromARGB(255, 63, 60, 61);

  static const snackbarSuccessContainerDark = Color.fromARGB(255, 14, 64, 22);
  static const snackbarSuccessOnContainerDark =
      Color.fromARGB(255, 229, 255, 223);
  static const snackbarFailureContainerDark = Color.fromARGB(255, 71, 15, 15);
  static const snackbarFailureOnContainerDark =
      Color.fromARGB(255, 255, 223, 215);
  static const snackbarInfoContainerDark = Color.fromARGB(255, 255, 248, 249);
  static const snackbarInfoOnContainerDark = Color.fromARGB(255, 6, 0, 1);
  static const snackbarUtilContainerDark = Color.fromARGB(255, 255, 248, 249);
  static const snackbarUtilOnContainerDark = Color.fromARGB(255, 6, 0, 1);
  static const snackbarActionTextColorDark = Color.fromARGB(255, 95, 14, 27);

  // Green
  static const green = Color.fromARGB(255, 140, 181, 94);

  // Grey
  static const grey = _GreyColors();

  static const likedRed = Colors.red;
  static const savedAmber = Color.fromARGB(255, 244, 136, 93);

  static const transparent = Colors.transparent;

  static const redditOrange = Color.fromARGB(255, 255, 69, 0);
  static const rssBlue = Color.fromARGB(255, 0, 145, 255);
  static const substackOrange = Color.fromARGB(255, 255, 119, 49);
  static const youtubeRed = Color.fromARGB(255, 255, 0, 0);
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
