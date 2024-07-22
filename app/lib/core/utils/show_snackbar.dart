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
      ),
    );
}
