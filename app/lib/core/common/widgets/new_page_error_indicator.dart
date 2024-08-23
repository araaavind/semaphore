import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NewPageErrorIndicator extends StatelessWidget {
  const NewPageErrorIndicator({
    super.key,
    required this.title,
    this.message = 'Something went wrong',
    this.onTap,
  });
  final VoidCallback? onTap;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.pagePadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 4.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tap to try again',
                      style: context.theme.textTheme.bodySmall!.copyWith(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.refresh,
                      size: 14,
                      weight: 0.5,
                      color: context.theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      );
}
