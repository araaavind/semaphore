import 'package:flutter/material.dart';

class AppSnackbarColorTheme extends ThemeExtension<AppSnackbarColorTheme> {
  final Color? networkOfflineContainer;
  final Color? networkOnlineContainer;
  final Color? networkOfflineOnContainer;
  final Color? networkOnlineOnContainer;

  AppSnackbarColorTheme({
    required this.networkOfflineContainer,
    required this.networkOnlineContainer,
    required this.networkOfflineOnContainer,
    required this.networkOnlineOnContainer,
  });

  @override
  ThemeExtension<AppSnackbarColorTheme> copyWith({
    Color? networkOfflineContainer,
    Color? networkOnlineContainer,
    Color? networkOfflineOnContainer,
    Color? networkOnlineOnContainer,
  }) {
    return AppSnackbarColorTheme(
      networkOfflineContainer:
          networkOfflineContainer ?? this.networkOfflineContainer,
      networkOnlineContainer:
          networkOnlineContainer ?? this.networkOnlineContainer,
      networkOfflineOnContainer:
          networkOfflineOnContainer ?? this.networkOfflineOnContainer,
      networkOnlineOnContainer:
          networkOnlineOnContainer ?? this.networkOnlineOnContainer,
    );
  }

  @override
  ThemeExtension<AppSnackbarColorTheme> lerp(
    AppSnackbarColorTheme? other,
    double t,
  ) {
    if (other == null) return this;
    return AppSnackbarColorTheme(
      networkOfflineContainer:
          Color.lerp(networkOfflineContainer, other.networkOfflineContainer, t),
      networkOnlineContainer:
          Color.lerp(networkOnlineContainer, other.networkOnlineContainer, t),
      networkOfflineOnContainer: Color.lerp(
          networkOfflineOnContainer, other.networkOfflineOnContainer, t),
      networkOnlineOnContainer: Color.lerp(
          networkOnlineOnContainer, other.networkOnlineOnContainer, t),
    );
  }
}
