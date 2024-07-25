import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NoMoreItemsIndicator extends StatelessWidget {
  const NoMoreItemsIndicator({
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
                TextConstants.feedListEmptyMessageTitle,
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4.0),
              Text(
                TextConstants.feedListEmptyMessageMessage,
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
