import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/theme/extensions/app_snackbar_color_theme.dart';
import 'package:flutter/material.dart';

enum SnackbarType { success, failure, warning, info, utility }

void showSnackbar(
  BuildContext context,
  String content, {
  required SnackbarType type,
  String? actionLabel,
  void Function()? onActionPressed,
  double bottomOffset = kToolbarHeight + 8,
}) {
  Color backgroundColor;
  Color textColor;
  switch (type) {
    case SnackbarType.success:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.successContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.successOnContainer!;
    case SnackbarType.failure:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.failureContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.failureOnContainer!;
    case SnackbarType.info:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoOnContainer!;
    case SnackbarType.utility:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.utilContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.utilOnContainer!;
    default:
      backgroundColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoContainer!;
      textColor =
          context.theme.extension<AppSnackbarColorTheme>()!.infoOnContainer!;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                content,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
                softWrap: (actionLabel != null && onActionPressed != null)
                    ? false
                    : true,
              ),
            ),
            if (actionLabel != null && onActionPressed != null)
              TextButton(
                style: TextButton.styleFrom(
                  overlayColor: AppPalette.transparent,
                  padding: const EdgeInsets.only(left: 16.0),
                ),
                onPressed: () {
                  onActionPressed();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text(
                  actionLabel,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme
                        .extension<AppSnackbarColorTheme>()!
                        .actionTextColor!,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.down,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomOffset,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical:
              (actionLabel != null && onActionPressed != null) ? 2.0 : 16.0,
        ),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.inputBorderRadius),
        ),
      ),
    );
}
