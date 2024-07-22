import 'package:app/core/constants/constants.dart';
import 'package:flutter/material.dart';

void showSnackbar(
  BuildContext context,
  String content, {
  Color? backgroundColor,
  Color? textColor,
}) {
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
