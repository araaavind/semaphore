import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Size? fixedSize;
  final bool isLoading;
  final Widget? suffixIcon;
  final bool filled;

  const Button({
    super.key,
    required this.text,
    this.textColor,
    this.textStyle,
    this.backgroundColor,
    this.fixedSize,
    this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: filled
            ? onPressed != null
                ? (backgroundColor ?? context.theme.colorScheme.primary)
                : context.theme.disabledColor
            : null,
        border: filled
            ? null
            : Border.all(
                width: 2,
                color: onPressed != null
                    ? (backgroundColor ?? context.theme.colorScheme.primary)
                    : context.theme.disabledColor,
              ),
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
      ),
      height: fixedSize?.height,
      width: fixedSize?.width,
      constraints: const BoxConstraints(),
      child: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        style: ElevatedButton.styleFrom(
          fixedSize: fixedSize,
          backgroundColor: AppPalette.transparent,
          shadowColor: AppPalette.transparent,
        ),
        label: Text(
          text,
          style: textStyle ??
              context.theme.textTheme.labelLarge?.copyWith(
                color: textColor ??
                    (filled
                        ? context.theme.colorScheme.onPrimary
                        : context.theme.colorScheme.primary),
              ),
        ),
        icon: isLoading
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  height: 14,
                  width: 14,
                  child: Loader(
                    color: filled
                        ? context.theme.colorScheme.onPrimary
                        : context.theme.colorScheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            : suffixIcon,
        onPressed: onPressed,
      ),
    );
  }
}
