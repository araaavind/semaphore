import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final Size? fixedSize;
  final bool isLoading;

  const Button({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.fixedSize,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: fixedSize ?? const Size(64, 36),
          backgroundColor: AppPalette.transparent,
          shadowColor: AppPalette.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: context.theme.textTheme.labelLarge?.copyWith(
                color: textColor ?? context.theme.colorScheme.onPrimary,
              ),
            ),
            isLoading
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: UIConstants.elementPadding),
                    child: SizedBox(
                      height: 14,
                      width: 14,
                      child: Loader(
                        color: context.theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
