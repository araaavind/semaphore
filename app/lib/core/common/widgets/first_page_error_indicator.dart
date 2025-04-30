import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'button.dart';

/// Basic layout for indicating that an exception occurred.
class FirstPageErrorIndicator extends StatelessWidget {
  const FirstPageErrorIndicator({
    required this.title,
    this.message,
    this.onTryAgain,
    super.key,
  });

  final String title;
  final String? message;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 24,
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.titleLarge,
            ),
            if (message != null)
              const SizedBox(
                height: 16,
              ),
            if (message != null)
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
            if (onTryAgain != null)
              const SizedBox(
                height: 24.0,
              ),
            if (onTryAgain != null)
              Button(
                text: 'Try again',
                backgroundColor: context.theme.colorScheme.primaryContainer,
                textColor: context.theme.colorScheme.onPrimaryContainer,
                onPressed: onTryAgain,
                suffixIcon: Icon(
                  MingCute.refresh_anticlockwise_line,
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
