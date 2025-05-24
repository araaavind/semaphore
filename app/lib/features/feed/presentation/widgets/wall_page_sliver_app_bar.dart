import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/features/feed/presentation/widgets/wall_page_sliver_app_bar_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WallPageSliverAppBar extends StatelessWidget {
  final bool isCollapsed;
  const WallPageSliverAppBar({
    super.key,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      pinned: true,
      snap: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.theme.colorScheme.surfaceContainer,
              context.theme.brightness == Brightness.dark
                  ? context.theme.colorScheme.surface.withAlpha(0)
                  : context.theme.colorScheme.surface.withAlpha(0),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight - 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.pagePadding),
              child: AnimatedOpacity(
                opacity: isCollapsed ? 0 : 1,
                duration: const Duration(milliseconds: 50),
                child: Text(
                  UIConstants.appBarTitle,
                  style: context.theme.textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.theme.brightness == Brightness.dark
                        ? AppPalette.brandDark
                        : AppPalette.brand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      toolbarHeight: 0,
      collapsedHeight: 8,
      expandedHeight: kToolbarHeight * 2.2,
      bottom: const WallPageSliverAppBarBottom(),
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: context.theme.colorScheme.surfaceContainer.withAlpha(0),
        statusBarIconBrightness: context.theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
