import 'package:flutter/material.dart';

class AppSnackbarColorTheme extends ThemeExtension<AppSnackbarColorTheme> {
  final Color? failureContainer;
  final Color? successContainer;
  final Color? infoContainer;
  final Color? utilContainer;
  final Color? failureOnContainer;
  final Color? successOnContainer;
  final Color? infoOnContainer;
  final Color? utilOnContainer;
  final Color? actionTextColor;

  AppSnackbarColorTheme({
    required this.failureContainer,
    required this.successContainer,
    required this.infoContainer,
    required this.utilContainer,
    required this.failureOnContainer,
    required this.successOnContainer,
    required this.infoOnContainer,
    required this.utilOnContainer,
    required this.actionTextColor,
  });

  @override
  ThemeExtension<AppSnackbarColorTheme> copyWith({
    Color? failureContainer,
    Color? successContainer,
    Color? infoContainer,
    Color? utilContainer,
    Color? failureOnContainer,
    Color? successOnContainer,
    Color? infoOnContainer,
    Color? utilOnContainer,
    Color? actionTextColor,
  }) {
    return AppSnackbarColorTheme(
      failureContainer: failureContainer ?? this.failureContainer,
      successContainer: successContainer ?? this.successContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      utilContainer: utilContainer ?? this.utilContainer,
      failureOnContainer: failureOnContainer ?? this.failureOnContainer,
      successOnContainer: successOnContainer ?? this.successOnContainer,
      infoOnContainer: infoOnContainer ?? this.infoOnContainer,
      utilOnContainer: utilOnContainer ?? this.utilOnContainer,
      actionTextColor: actionTextColor ?? this.actionTextColor,
    );
  }

  @override
  ThemeExtension<AppSnackbarColorTheme> lerp(
    AppSnackbarColorTheme? other,
    double t,
  ) {
    if (other == null) return this;
    return AppSnackbarColorTheme(
      failureContainer: Color.lerp(failureContainer, other.failureContainer, t),
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      utilContainer: Color.lerp(utilContainer, other.utilContainer, t),
      failureOnContainer:
          Color.lerp(failureOnContainer, other.failureOnContainer, t),
      successOnContainer:
          Color.lerp(successOnContainer, other.successOnContainer, t),
      infoOnContainer: Color.lerp(infoOnContainer, other.infoOnContainer, t),
      utilOnContainer: Color.lerp(utilOnContainer, other.utilOnContainer, t),
      actionTextColor: Color.lerp(actionTextColor, other.actionTextColor, t),
    );
  }
}
