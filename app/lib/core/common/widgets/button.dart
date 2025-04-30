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
  final Color? borderColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? suffixIcon;
  final bool filled;

  const Button({
    super.key,
    required this.text,
    this.textColor,
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
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
                ? (backgroundColor ?? context.theme.colorScheme.onSurface)
                : context.theme.disabledColor
            : null,
        border: filled
            ? null
            : Border.all(
                width: 1,
                color: onPressed != null
                    ? (borderColor ??
                        backgroundColor ??
                        context.theme.colorScheme.onSurface)
                    : context.theme.disabledColor,
              ),
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
      ),
      height: height ?? 46,
      width: width,
      constraints: const BoxConstraints(),
      child: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        style: ElevatedButton.styleFrom(
          maximumSize: Size(width ?? double.infinity, height ?? 46),
          backgroundColor: AppPalette.transparent,
          shadowColor: AppPalette.transparent,
        ),
        label: Padding(
          padding: suffixIcon != null
              ? const EdgeInsets.only(left: 8.0)
              : const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: textStyle ??
                context.theme.textTheme.titleMedium?.copyWith(
                  color: textColor ??
                      (filled
                          ? context.theme.colorScheme.surface
                          : context.theme.colorScheme.onSurface),
                ),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                height: 14,
                width: 14,
                child: Loader(
                  color: textColor ??
                      (filled
                          ? context.theme.colorScheme.surface
                          : context.theme.colorScheme.onSurface),
                  strokeWidth: 2,
                ),
              )
            : suffixIcon,
        onPressed: onPressed,
      ),
    );
  }
}
