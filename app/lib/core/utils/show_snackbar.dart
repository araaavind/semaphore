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
  double bottomOffset = 0,
  ScaffoldMessengerState? messengerState,
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

  final scaffoldMessenger = messengerState ?? ScaffoldMessenger.of(context);

  scaffoldMessenger
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
                  scaffoldMessenger.hideCurrentSnackBar();
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
          bottom: 16 + bottomOffset,
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

/// Helper function to create a new ScaffoldMessenger scope for nested Scaffolds
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return NestedScaffoldMessenger(
///     child: Scaffold(
///       // Your nested scaffold content
///     ),
///   );
/// }
/// ```
class NestedScaffoldMessenger extends StatefulWidget {
  final Widget child;

  const NestedScaffoldMessenger({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NestedScaffoldMessenger> createState() =>
      _NestedScaffoldMessengerState();
}

class _NestedScaffoldMessengerState extends State<NestedScaffoldMessenger> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: widget.child,
    );
  }

  // Access the ScaffoldMessengerState from parent widgets
  ScaffoldMessengerState? get messengerState =>
      _scaffoldMessengerKey.currentState;
}
