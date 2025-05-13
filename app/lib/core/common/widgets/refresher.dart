import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Refresher extends StatelessWidget {
  const Refresher({
    required this.controller,
    this.header,
    this.onRefresh,
    this.child,
    super.key,
  });

  final RefreshController controller;
  final void Function()? onRefresh;
  final Widget? child;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      onRefresh: onRefresh,
      header: header ??
          WaterDropMaterialHeader(
            backgroundColor: context.theme.colorScheme.primary.withOpacity(0.8),
            color: context.theme.colorScheme.onSurface.withOpacity(0.8),
            distance: 50.0,
          ),
      child: child,
    );
  }
}
