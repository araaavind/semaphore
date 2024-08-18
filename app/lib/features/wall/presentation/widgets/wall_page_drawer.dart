import 'package:app/core/common/widgets/loader.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/wall/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WallPageDrawer extends StatelessWidget {
  const WallPageDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: ListView(
        children: [
          ExpansionTile(
            childrenPadding: const EdgeInsets.all(16),
            shape: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Theme.of(context).dividerColor.withOpacity(0.8),
              ),
            ),
            collapsedShape: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Theme.of(context).dividerColor.withOpacity(0.8),
              ),
            ),
            initiallyExpanded: true,
            title: const Text(
              'Your walls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            e.name,
                            style: context.theme.textTheme.titleMedium,
                          ),
                          onTap: () {
                            Navigator.pop(context);
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
            childrenPadding: const EdgeInsets.all(16),
            shape: Border.all(
              width: 0,
            ),
            initiallyExpanded: true,
            title: const Text(
              'All feeds',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Hackernews',
                  style: context.theme.textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Reddit',
                  style: context.theme.textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Zerodha Tech',
                  style: context.theme.textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Kent C. Dodds',
                  style: context.theme.textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
