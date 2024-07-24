import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final Size? fixedSize;
  final bool isLoading;
  final Widget? suffixIcon;

  const Button({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.fixedSize,
    this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null
            ? (backgroundColor ?? context.theme.colorScheme.primary)
            : context.theme.disabledColor,
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
      ),
      child: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        style: ElevatedButton.styleFrom(
          fixedSize: fixedSize ?? UIConstants.defaultButtonFixedSize,
          backgroundColor: AppPalette.transparent,
          shadowColor: AppPalette.transparent,
        ),
        label: Text(
          text,
          style: context.theme.textTheme.labelLarge?.copyWith(
            color: textColor ?? context.theme.colorScheme.onPrimary,
          ),
        ),
        icon: isLoading
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  height: 14,
                  width: 14,
                  child: Loader(
                    color: context.theme.colorScheme.onPrimary,
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
