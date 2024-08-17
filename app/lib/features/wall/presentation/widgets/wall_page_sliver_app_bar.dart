import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class WallPageSliverAppBar extends StatelessWidget {
  const WallPageSliverAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        'smphr',
        style: context.theme.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: context.theme.colorScheme.secondary,
        ),
      ),
      floating: true,
      pinned: true,
      snap: false,
      stretch: true,
      automaticallyImplyLeading: false,
    );
  }
}
