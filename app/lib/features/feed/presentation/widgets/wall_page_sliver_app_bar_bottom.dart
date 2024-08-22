import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WallPageSliverAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const WallPageSliverAppBarBottom({
    required this.title,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kBottomNavigationBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // this will hide Drawer hamburger icon
      // backgroundColor: context.theme.colorScheme.surfaceContainerLow,
      title: GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              color: context.theme.colorScheme.onSurface.withOpacity(0.85),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          color: context.theme.colorScheme.onSurface.withOpacity(0.85),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          color: context.theme.colorScheme.onSurface.withOpacity(0.85),
        ),
      ],
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }
}
