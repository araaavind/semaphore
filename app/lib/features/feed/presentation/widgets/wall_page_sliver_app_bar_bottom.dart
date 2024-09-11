import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WallPageSliverAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final Wall wall;
  const WallPageSliverAppBarBottom({
    required this.wall,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kBottomNavigationBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // this will hide Drawer hamburger icon
      backgroundColor: context.theme.colorScheme.surfaceContainerLowest,
      shape: Border(
        top: BorderSide(
          color: context.theme.colorScheme.outline.withOpacity(0.8),
          width: 0.2,
        ),
        bottom: BorderSide(
          color: context.theme.colorScheme.outline.withOpacity(0.8),
          width: 0.2,
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_right,
              color: context.theme.colorScheme.onSurface.withOpacity(0.85),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                wall.name,
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
        if (!wall.isPrimary)
          IconButton(
            onPressed: () {
              context.pushNamed(
                RouteConstants.wallViewPageName,
                pathParameters: {'wallId': wall.id.toString()},
                extra: wall,
              );
            },
            icon: const Icon(Icons.edit_note),
            color: context.theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        IconButton(
          onPressed: () {
            _showFilterModal(context);
          },
          icon: const Icon(Icons.filter_list),
          color: context.theme.colorScheme.onSurface.withOpacity(0.85),
        ),
      ],
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }
}

void _showFilterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.brightness == Brightness.dark
        ? context.theme.colorScheme.surfaceContainerLowest
        : context.theme.colorScheme.surface,
    showDragHandle: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SizedBox(
        height: 540,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'View options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                thickness: 0.5,
                color: context.theme.colorScheme.outline,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final selectedWallSort =
                        context.read<WallsBloc>().state.wallSort;
                    final selectedWallView =
                        context.read<WallsBloc>().state.wallView;
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        _buildSectionTitle('Sort by'),
                        _buildOptionItem(
                          context: context,
                          title: WallSortOption.hot.name,
                          icon: Icons.local_fire_department,
                          isSelected: WallSortOption.hot == selectedWallSort,
                        ),
                        _buildOptionItem(
                          context: context,
                          title: WallSortOption.latest.name,
                          icon: Icons.fiber_new,
                          isSelected: WallSortOption.latest == selectedWallSort,
                        ),
                        _buildOptionItem(
                          context: context,
                          title: WallSortOption.top.name,
                          icon: Icons.bar_chart,
                          isSelected: WallSortOption.top == selectedWallSort,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: context.theme.colorScheme.outline,
                        ),
                        _buildSectionTitle('View'),
                        _buildOptionItem(
                          context: context,
                          title: WallViewOption.card.name,
                          icon: Icons.view_agenda,
                          isSelected: WallViewOption.card == selectedWallView,
                        ),
                        _buildOptionItem(
                          context: context,
                          title: WallViewOption.magazine.name,
                          icon: Icons.view_list,
                          isSelected:
                              WallViewOption.magazine == selectedWallView,
                        ),
                        _buildOptionItem(
                          context: context,
                          title: WallViewOption.text.name,
                          icon: Icons.text_fields,
                          isSelected: WallViewOption.text == selectedWallView,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildOptionItem({
  required BuildContext context,
  required String title,
  required IconData icon,
  bool isSelected = false,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isSelected ? context.theme.colorScheme.primary : Colors.grey,
    ),
    title: Text(
      title,
      style: TextStyle(
          color: isSelected ? context.theme.colorScheme.primary : null),
    ),
    trailing: isSelected
        ? Icon(Icons.check, color: context.theme.colorScheme.primary)
        : null,
    onTap: () {
      if (title == WallSortOption.hot.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallSort: WallSortOption.hot),
            );
      } else if (title == WallSortOption.latest.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallSort: WallSortOption.latest),
            );
      } else if (title == WallSortOption.trending.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallSort: WallSortOption.trending),
            );
      } else if (title == WallSortOption.top.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallSort: WallSortOption.top),
            );
      } else if (title == WallViewOption.card.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallView: WallViewOption.card),
            );
      } else if (title == WallViewOption.magazine.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallView: WallViewOption.magazine),
            );
      } else if (title == WallViewOption.text.name) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(wallView: WallViewOption.text),
            );
      }
      context.pop();
    },
  );
}
