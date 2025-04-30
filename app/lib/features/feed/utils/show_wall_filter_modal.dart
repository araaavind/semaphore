import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void showWallFilterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.colorScheme.surface,
    showDragHandle: false,
    isScrollControlled: true,
    barrierColor: context.theme.colorScheme.surfaceContainer.withAlpha(180),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
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
                  Text(
                    'View options',
                    style: context.theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                          icon: MingCute.fire_fill,
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
                          icon: MingCute.rows_3_fill,
                          isSelected: WallViewOption.card == selectedWallView,
                        ),
                        _buildOptionItem(
                          context: context,
                          title: WallViewOption.magazine.name,
                          icon: MingCute.list_check_3_fill,
                          isSelected:
                              WallViewOption.magazine == selectedWallView,
                        ),
                        _buildOptionItem(
                          context: context,
                          title: WallViewOption.text.name,
                          icon: MingCute.menu_fill,
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 32),
    leading: Icon(
      icon,
      color: isSelected
          ? context.theme.colorScheme.primary
          : context.theme.colorScheme.onSurface.withOpacity(0.6),
    ),
    title: Text(
      title,
      style: TextStyle(
          color: isSelected
              ? context.theme.colorScheme.primary
              : context.theme.colorScheme.onSurface.withOpacity(0.6)),
    ),
    tileColor: isSelected
        ? context.theme.colorScheme.primaryContainer
        : context.theme.colorScheme.surface,
    visualDensity: VisualDensity.compact,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConstants.tileItemBorderRadius),
    ),
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
