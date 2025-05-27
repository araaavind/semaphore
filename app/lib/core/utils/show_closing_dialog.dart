import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool?> showClosingDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Exit App'),
      content: const Text('Are you sure you want to exit the app?'),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(
            'No',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: Text(
            'Yes',
            style: TextStyle(
              color: context.theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
