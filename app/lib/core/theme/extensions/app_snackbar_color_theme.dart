import 'package:flutter/material.dart';

class AppSnackbarColorTheme extends ThemeExtension<AppSnackbarColorTheme> {
  final Color? failureContainer;
  final Color? successContainer;
  final Color? infoContainer;
  final Color? failureOnContainer;
  final Color? successOnContainer;
  final Color? infoOnContainer;

  AppSnackbarColorTheme({
    required this.failureContainer,
    required this.successContainer,
    required this.infoContainer,
    required this.failureOnContainer,
    required this.successOnContainer,
    required this.infoOnContainer,
  });

  @override
  ThemeExtension<AppSnackbarColorTheme> copyWith({
    Color? failureContainer,
    Color? successContainer,
    Color? infoContainer,
    Color? failureOnContainer,
    Color? successOnContainer,
    Color? infoOnContainer,
  }) {
    return AppSnackbarColorTheme(
      failureContainer: failureContainer ?? this.failureContainer,
      successContainer: successContainer ?? this.successContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      failureOnContainer: failureOnContainer ?? this.failureOnContainer,
      successOnContainer: successOnContainer ?? this.successOnContainer,
      infoOnContainer: infoOnContainer ?? this.infoOnContainer,
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
      failureOnContainer:
          Color.lerp(failureOnContainer, other.failureOnContainer, t),
      successOnContainer:
          Color.lerp(successOnContainer, other.successOnContainer, t),
      infoOnContainer: Color.lerp(infoOnContainer, other.infoOnContainer, t),
    );
  }
}
