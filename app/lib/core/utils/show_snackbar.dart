import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/theme/extensions/app_snackbar_color_theme.dart';
import 'package:flutter/material.dart';

enum SnackbarType { success, failure, warning, info, utility }

void showSnackbar(
  BuildContext context,
  String content, {
  required SnackbarType type,
}) {
  Color backgroundColor;
  Color textColor;
  switch (type) {
    case SnackbarType.success:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.successContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.successOnContainer!;
    case SnackbarType.failure:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.failureContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.failureOnContainer!;
    case SnackbarType.info:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoOnContainer!;
    default:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoOnContainer!;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: TextStyle(
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 16.0,
        ),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.inputBorderRadius),
        ),
      ),
    );
}
