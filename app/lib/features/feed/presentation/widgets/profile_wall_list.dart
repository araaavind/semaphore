import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileWallList extends StatefulWidget {
  const ProfileWallList({super.key});

  @override
  State<ProfileWallList> createState() => _ProfileWallListState();
}

class _ProfileWallListState extends State<ProfileWallList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocConsumer<WallsBloc, WallsState>(
        listener: (context, state) {
          if (state.status == WallStatus.success &&
              state.action == WallAction.create) {
            context
                .read<WallsBloc>()
                .add(ListWallsRequested(refreshItems: false));
            return;
          } else if (state.status == WallStatus.success &&
              state.action == WallAction.delete) {
            // Select the primary wall to navigate back to
            final walls = context.read<WallsBloc>().state.walls;
            Wall? pinnedWall;
            try {
              pinnedWall = walls.firstWhere((element) => element.isPinned);
            } catch (e) {
              pinnedWall = null;
            }
            context.read<WallsBloc>().add(
                  SelectWallRequested(
                    selectedWall: pinnedWall ??
                        walls.firstWhere((element) => element.isPrimary),
                  ),
                );
            context
                .read<WallsBloc>()
                .add(ListWallsRequested(refreshItems: false));
            return;
          } else if (state.status == WallStatus.success &&
              state.action == WallAction.update) {
            context
                .read<WallsBloc>()
                .add(ListWallsRequested(refreshItems: false));
            return;
          } else if (state.status == WallStatus.success &&
              (state.action == WallAction.pin ||
                  state.action == WallAction.unpin)) {
            context
                .read<WallsBloc>()
                .add(ListWallsRequested(refreshItems: false));
            return;
          }

          if (state.status == WallStatus.failure) {
            showSnackbar(context, state.message!, type: SnackbarType.failure);
            return;
          }
        },
        builder: (context, state) {
          if (state.status == WallStatus.initial) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No walls found',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (state.status == WallStatus.failure) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Unable to load walls'),
              ),
            );
          }

          final nonPrimaryWalls =
              state.walls.where((e) => !e.isPrimary).toList();

          if (nonPrimaryWalls.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You haven\'t created any walls yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 12.0),
            itemCount: nonPrimaryWalls.length,
            itemBuilder: (context, index) {
              final wall = nonPrimaryWalls[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.pagePadding,
                ),
                child: _WallListTile(
                  wall: wall,
                  pinnedWallId: state.pinnedWallId,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            context.pushNamed(RouteConstants.createWallPageName);
          },
          elevation: 2,
          backgroundColor: context.theme.colorScheme.primaryContainer,
          foregroundColor: context.theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.add),
          tooltip: 'Create Wall',
        ),
      ),
    );
  }
}

class _WallListTile extends StatelessWidget {
  final Wall wall;
  final int? pinnedWallId;

  const _WallListTile({
    required this.wall,
    required this.pinnedWallId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.standard,
      title: Text(
        wall.name,
        style: context.theme.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: UIConstants.tileContentPadding,
      ),
      splashColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(
          width: 0.5,
          color: context.theme.colorScheme.outline,
        ),
      ),
      leading: pinnedWallId != null && wall.id == pinnedWallId
          ? GestureDetector(
              onTap: () {
                context
                    .read<WallsBloc>()
                    .add(UnpinWallRequested(wallId: wall.id));
              },
              child: Container(
                padding: const EdgeInsets.only(left: 0),
                child: Icon(
                  MingCute.pin_2_fill,
                  color: context.theme.colorScheme.onSurface.withAlpha(217),
                ),
              ),
            )
          : wall.isPrimary
              ? null
              : GestureDetector(
                  onTap: () {
                    context
                        .read<WallsBloc>()
                        .add(PinWallRequested(wallId: wall.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 0),
                    child: Icon(
                      MingCute.pin_line,
                      color: context.theme.colorScheme.onSurface.withAlpha(217),
                    ),
                  ),
                ),
      onTap: () {
        if (!wall.isPrimary) {
          context.pushNamed(
            RouteConstants.wallEditPageName,
            pathParameters: {'wallId': wall.id.toString()},
            extra: wall,
          );
        }
        // context.read<WallsBloc>().add(
        //       SelectWallRequested(selectedWall: wall),
        //     );
        // context.pushNamed(
        //   RouteConstants.wallPageName,
        //   extra: context.read<WallsBloc>(),
        // );
      },
    );
  }
}
