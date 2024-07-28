import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_color_scheme.dart';
import 'package:app/core/theme/app_text_theme.dart';
import 'package:app/core/theme/extensions/app_snackbar_color_theme.dart';
import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}

class AppTheme {
  static _border({Color color = AppPalette.outline, double width = 1}) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
        borderRadius: BorderRadius.circular(
          UIConstants.inputBorderRadius,
        ),
      );

  static final light = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    colorScheme: AppColorScheme.lightColorScheme,
    disabledColor: AppPalette.disabledPrimary,
    scaffoldBackgroundColor: AppColorScheme.lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColorScheme.lightColorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.grey.shade50,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorScheme.lightColorScheme.surface,
      elevation: 6.0,
      selectedItemColor: AppColorScheme.lightColorScheme.primary,
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(UIConstants.contentPadding),
      border: _border(color: AppColorScheme.lightColorScheme.outline),
      enabledBorder: _border(color: AppColorScheme.lightColorScheme.outline),
      focusedBorder: _border(
        color: AppColorScheme.lightColorScheme.secondary,
      ),
      errorBorder: _border(color: AppColorScheme.lightColorScheme.error),
    ),
    textTheme: AppTextTheme.lightTextTheme,
    extensions: [
      AppSnackbarColorTheme(
        networkOfflineContainer: AppPalette.networkOfflineSnackbarContainer,
        networkOfflineOnContainer: AppPalette.networkOfflineSnackbarOnContainer,
        networkOnlineContainer: AppPalette.networkOnlineSnackbarContainer,
        networkOnlineOnContainer: AppPalette.networkOnlineSnackbarOnContainer,
      ),
    ],
  );
  static final dark = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    colorScheme: AppColorScheme.darkColorScheme,
    disabledColor: AppPalette.disabledPrimaryDark,
    scaffoldBackgroundColor: AppColorScheme.darkColorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColorScheme.darkColorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.grey.shade700,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorScheme.darkColorScheme.surface,
      elevation: 6.0,
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      selectedItemColor: AppColorScheme.darkColorScheme.primary,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(UIConstants.contentPadding),
      border: _border(color: AppColorScheme.darkColorScheme.outline),
      enabledBorder: _border(color: AppColorScheme.darkColorScheme.outline),
      focusedBorder: _border(
        color: AppColorScheme.darkColorScheme.secondary,
      ),
      errorBorder: _border(color: AppColorScheme.darkColorScheme.error),
    ),
    textTheme: AppTextTheme.darkTextTheme,
    extensions: [
      AppSnackbarColorTheme(
        networkOfflineContainer: AppPalette.networkOfflineSnackbarContainerDark,
        networkOfflineOnContainer:
            AppPalette.networkOfflineSnackbarOnContainerDark,
        networkOnlineContainer: AppPalette.networkOnlineSnackbarContainerDark,
        networkOnlineOnContainer:
            AppPalette.networkOnlineSnackbarOnContainerDark,
      ),
    ],
  );
}
