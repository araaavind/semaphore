import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String noButtonText = 'No',
  String yesButtonText = 'Yes',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(
            noButtonText,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: Text(
            yesButtonText,
            style: TextStyle(
              color: context.theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
