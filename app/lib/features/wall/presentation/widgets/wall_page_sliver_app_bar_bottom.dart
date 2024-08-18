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
      backgroundColor: context.theme.colorScheme.surfaceContainerLow,
      title: GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.menu,
                size: 20,
                weight: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: context.theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          iconSize: 22,
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        IconButton(
          iconSize: 22,
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
        ),
      ],
      shape: Border(
        top: BorderSide(
          color: context.theme.colorScheme.outline,
          width: 0.1,
        ),
        bottom: BorderSide(
          color: context.theme.colorScheme.outline,
          width: 0.1,
        ),
      ),
    );
  }
}
