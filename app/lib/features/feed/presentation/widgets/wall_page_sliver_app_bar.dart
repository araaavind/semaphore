import 'package:app/core/theme/theme.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/widgets/wall_page_sliver_app_bar_bottom.dart';
import 'package:flutter/material.dart';

class WallPageSliverAppBar extends StatelessWidget {
  final Wall wall;
  const WallPageSliverAppBar({
    required this.wall,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        'Semaphore',
        style: context.theme.textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w900,
          color: context.theme.brightness == Brightness.dark
              ? AppPalette.brandDark
              : AppPalette.brand,
        ),
      ),
      floating: true,
      pinned: true,
      snap: false,
      stretch: true,
      automaticallyImplyLeading: false,
      bottom: WallPageSliverAppBarBottom(
        wall: wall,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
