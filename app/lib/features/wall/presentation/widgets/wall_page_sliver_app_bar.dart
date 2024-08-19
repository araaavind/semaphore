import 'package:app/core/theme/theme.dart';
import 'package:app/features/wall/presentation/widgets/wall_page_sliver_app_bar_bottom.dart';
import 'package:flutter/material.dart';

class WallPageSliverAppBar extends StatelessWidget {
  final String bottomBarTitle;
  const WallPageSliverAppBar({
    required this.bottomBarTitle,
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
      bottom: WallPageSliverAppBarBottom(
        title: bottomBarTitle,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
