import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color? color;
  final double strokeWidth;

  const Loader({
    super.key,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 20.0,
        width: 20.0,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color ?? context.theme.colorScheme.primary.withAlpha(127),
        ),
      ),
    );
  }
}
