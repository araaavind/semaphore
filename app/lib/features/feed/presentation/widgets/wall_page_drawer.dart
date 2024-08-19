import 'package:app/core/common/widgets/loader.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WallPageDrawer extends StatelessWidget {
  const WallPageDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 4.0,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      child: ListView(
        children: [
          ExpansionTile(
            childrenPadding: const EdgeInsets.all(8.0),
            expansionAnimationStyle: AnimationStyle(
              curve: Curves.easeOut,
              duration: Durations.short3,
            ),
            shape: Border(
              bottom: BorderSide(
                width: 0,
                color: context.theme.colorScheme.outline,
              ),
            ),
            collapsedShape: Border(
              bottom: BorderSide(
                width: 0,
                color: context.theme.colorScheme.outline,
              ),
            ),
            initiallyExpanded: true,
            title: Text(
              'Your walls',
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            children: [
              BlocBuilder<WallsBloc, WallsState>(
                builder: (context, state) {
                  if (state.status == WallsStatus.initial) {
                    return const SizedBox.shrink();
                  }
                  if (state.status == WallsStatus.failure) {
                    return const Text('Unable to load walls');
                  }
                  if (state.status == WallsStatus.loading) {
                    return const Loader();
                  }
                  return Column(
                    children: [
                      ...state.walls.map(
                        (e) => ListTile(
                          selected: e.id == state.currentWall!.id,
                          selectedTileColor:
                              context.theme.colorScheme.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              UIConstants.inputBorderRadius,
                            ),
                          ),
                          selectedColor: context.theme.colorScheme.primary,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            e.name,
                            style: context.theme.textTheme.titleSmall,
                          ),
                          onTap: () {
                            context.pop();
                            context
                                .read<WallsBloc>()
                                .add(SelectWallRequested(selectedWall: e));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            childrenPadding: const EdgeInsets.all(8.0),
            shape: Border.all(
              width: 0,
            ),
            collapsedShape: Border.all(
              width: 0,
            ),
            initiallyExpanded: true,
            title: Text(
              'All feeds',
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            expansionAnimationStyle: AnimationStyle(
              curve: Curves.easeOut,
              duration: Durations.short3,
            ),
            children: [
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Hackernews',
                  style: context.theme.textTheme.titleSmall,
                ),
                onTap: () {
                  context.pop();
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Reddit',
                  style: context.theme.textTheme.titleSmall,
                ),
                onTap: () {
                  context.pop();
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Zerodha Tech',
                  style: context.theme.textTheme.titleSmall,
                ),
                onTap: () {
                  context.pop();
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Kent C. Dodds',
                  style: context.theme.textTheme.titleSmall,
                ),
                onTap: () {
                  context.pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
