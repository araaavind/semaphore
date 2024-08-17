import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NoMoreItemsIndicator extends StatelessWidget {
  final String title;
  final String? message;
  const NoMoreItemsIndicator({
    this.title = 'Nothing to see here',
    this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.theme.colorScheme.outline,
              width: UIConstants.borderWidth,
            ),
          ),
        ),
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
              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
        ),
      );
}
