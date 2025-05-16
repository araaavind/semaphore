import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileWallList extends StatelessWidget {
  const ProfileWallList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallsBloc, WallsState>(
      listener: (context, state) {
        if (state.status == WallStatus.success &&
            state.action == WallAction.create) {
          context.read<WallsBloc>().add(ListWallsRequested());
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
          context.read<WallsBloc>().add(ListWallsRequested());
          return;
        } else if (state.status == WallStatus.success &&
            state.action == WallAction.update) {
          context.read<WallsBloc>().add(ListWallsRequested());
          return;
        } else if (state.status == WallStatus.success &&
            (state.action == WallAction.pin ||
                state.action == WallAction.unpin)) {
          context.read<WallsBloc>().add(ListWallsRequested());
          return;
        }

        if (state.status == WallStatus.failure) {
          showSnackbar(context, state.message!, type: SnackbarType.failure);
          return;
        }
      },
      buildWhen: (previous, current) {
        return current.status == WallStatus.success &&
            current.action == WallAction.list;
      },
      builder: (context, state) {
        if (state.status == WallStatus.initial) {
          return const SizedBox.shrink();
        } else if (state.status == WallStatus.failure) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Unable to load walls'),
            ),
          );
        }

        if (state.walls.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No walls found',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 12.0),
          itemCount: state.walls.length,
          itemBuilder: (context, index) {
            final wall = state.walls[index];
            return _WallListTile(
              wall: wall,
              pinnedWallId: state.pinnedWallId,
            );
          },
        );
      },
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
        horizontal: UIConstants.pagePadding,
      ),
      splashColor: Colors.transparent,
      trailing: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16.0,
        children: [
          SizedBox(
            child: pinnedWallId != null && wall.id == pinnedWallId
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
                        color: context.theme.colorScheme.onSurface
                            .withOpacity(0.85),
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
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(0.85),
                          ),
                        ),
                      ),
          ),
          if (!wall.isPrimary)
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  RouteConstants.wallEditPageName,
                  pathParameters: {'wallId': wall.id.toString()},
                  extra: wall,
                );
              },
              child: Icon(
                MingCute.pencil_line,
                color: context.theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
        ],
      ),
      onTap: () {
        context.read<WallsBloc>().add(
              SelectWallRequested(selectedWall: wall),
            );
        context.pushNamed(
          RouteConstants.wallPageName,
          extra: context.read<WallsBloc>(),
        );
      },
    );
  }
}
