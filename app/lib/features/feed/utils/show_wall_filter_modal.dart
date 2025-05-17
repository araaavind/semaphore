import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/user_preferences_service.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void showWallFilterModal(BuildContext context) {
  final userPrefs = serviceLocator<UserPreferencesService>();
  showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.colorScheme.surface,
    showDragHandle: false,
    isScrollControlled: true,
    barrierColor: context.theme.colorScheme.surfaceContainer.withAlpha(180),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero)),
    builder: (context) {
      return BlocBuilder<WallsBloc, WallsState>(
        buildWhen: (previous, current) {
          return current.action == WallAction.savePreference ||
              current.action == WallAction.changeFilter;
        },
        builder: (context, state) {
          final selectedWallSort = state.wallSort;
          final selectedWallView = state.wallView;
          final defaultSort = userPrefs.getDefaultWallSort();
          final defaultView = userPrefs.getDefaultWallView();
          return SizedBox(
            height: 520,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'View options',
                  //       style: context.theme.textTheme.titleLarge!.copyWith(
                  //         fontWeight: FontWeight.w800,
                  //       ),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () => context.pop(),
                  //       child: const Icon(Icons.close),
                  //     )
                  //   ],
                  // ),
                  // const SizedBox(height: 10),
                  // Divider(
                  //   thickness: 0.5,
                  //   color: context.theme.colorScheme.outline,
                  // ),
                  // const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        _buildSectionTitle('Sort by'),
                        _buildOptionItem(
                          context: context,
                          option: WallSortOption.hot,
                          icon: MingCute.fire_fill,
                          isSelected: WallSortOption.hot == selectedWallSort,
                          isDefault: defaultSort == WallSortOption.hot,
                        ),
                        _buildOptionItem(
                          context: context,
                          option: WallSortOption.latest,
                          icon: Icons.fiber_new,
                          isSelected: WallSortOption.latest == selectedWallSort,
                          isDefault: defaultSort == WallSortOption.latest,
                        ),
                        _buildOptionItem(
                          context: context,
                          option: WallSortOption.top,
                          icon: Icons.bar_chart,
                          isSelected: WallSortOption.top == selectedWallSort,
                          isDefault: defaultSort == WallSortOption.top,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: context.theme.colorScheme.outline,
                        ),
                        _buildSectionTitle('View'),
                        _buildOptionItem(
                          context: context,
                          option: WallViewOption.card,
                          icon: MingCute.rows_3_fill,
                          isSelected: WallViewOption.card == selectedWallView,
                          isDefault: defaultView == WallViewOption.card,
                        ),
                        _buildOptionItem(
                          context: context,
                          option: WallViewOption.magazine,
                          icon: MingCute.list_check_3_fill,
                          isSelected:
                              WallViewOption.magazine == selectedWallView,
                          isDefault: defaultView == WallViewOption.magazine,
                        ),
                        _buildOptionItem(
                          context: context,
                          option: WallViewOption.text,
                          icon: MingCute.menu_fill,
                          isSelected: WallViewOption.text == selectedWallView,
                          isDefault: defaultView == WallViewOption.text,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Button(
                    text: 'Done',
                    height: 40,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildOptionItem<T>({
  required BuildContext context,
  required T option,
  required IconData icon,
  bool isSelected = false,
  bool isDefault = false,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(
      icon,
      color: isSelected
          ? context.theme.colorScheme.onPrimaryContainer
          : context.theme.colorScheme.onSurface.withOpacity(0.6),
    ),
    title: Text(
      (option as dynamic).name,
      style: TextStyle(
          color: isSelected
              ? context.theme.colorScheme.onPrimaryContainer
              : context.theme.colorScheme.onSurface.withOpacity(0.6)),
    ),
    trailing: isDefault
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Default',
              style: TextStyle(
                color: context.theme.colorScheme.primary.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        : isSelected
            ? TextButton(
                onPressed: () {
                  if (T == WallSortOption) {
                    context.read<WallsBloc>().add(
                          SaveAsDefaultPreference(
                            sortOption: option as WallSortOption,
                          ),
                        );
                  } else if (T == WallViewOption) {
                    context.read<WallsBloc>().add(
                          SaveAsDefaultPreference(
                            viewOption: option as WallViewOption,
                          ),
                        );
                  }
                },
                child: const Text(
                  'Set as default',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
    tileColor: isSelected
        ? context.theme.colorScheme.primaryContainer
        : context.theme.colorScheme.surface,
    visualDensity: VisualDensity.compact,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConstants.tileItemBorderRadius),
    ),
    onTap: () {
      isSelected = true;
      if (T == WallSortOption) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(
                wallSort: option as WallSortOption,
              ),
            );
      } else if (T == WallViewOption) {
        context.read<WallsBloc>().add(
              ChangeWallOptions(
                wallView: option as WallViewOption,
              ),
            );
      }
    },
  );
}
