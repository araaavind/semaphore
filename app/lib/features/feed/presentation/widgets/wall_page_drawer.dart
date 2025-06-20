import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WallPageDrawer extends StatelessWidget {
  const WallPageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 6.0,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      shadowColor: Colors.black.withAlpha(160),
      child: SafeArea(
        child: BlocBuilder<WallsBloc, WallsState>(
          builder: (context, state) {
            if (state.status == WallStatus.initial) {
              return const SizedBox.shrink();
            } else if (state.action == WallAction.list &&
                state.status == WallStatus.failure) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Unable to load walls'),
                ),
              );
            }
            return ListView(
              children: [
                ExpansionTile(
                  childrenPadding: const EdgeInsets.all(8.0),
                  trailing: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surfaceContainer
                            .withAlpha(0),
                      ),
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        right: 2.0,
                        top: 12.0,
                        bottom: 14.0,
                      ),
                      child: const Icon(
                        MingCute.add_fill,
                        size: 22,
                      ),
                    ),
                    onTap: () async {
                      context.pushNamed(
                        RouteConstants.createWallPageName,
                      );
                    },
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  expansionAnimationStyle: AnimationStyle(
                    curve: Curves.easeOut,
                    duration: Durations.short3,
                  ),
                  shape: Border(
                    bottom: BorderSide(
                      width: 0,
                      color: context.theme.colorScheme.outline.withAlpha(0),
                    ),
                  ),
                  collapsedShape: Border(
                    bottom: BorderSide(
                      width: 0,
                      color: context.theme.colorScheme.outline.withAlpha(0),
                    ),
                  ),
                  initiallyExpanded: true,
                  title: Text(
                    'Your walls',
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  children: _buildWallTiles(state, context),
                ),
                ExpansionTile(
                  trailing: GestureDetector(
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Icon(
                        MingCute.add_fill,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      context.goNamed(RouteConstants.searchFeedsPageName);
                    },
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  childrenPadding: const EdgeInsets.all(8.0),
                  shape: Border.all(
                    width: 0,
                    color: context.theme.colorScheme.outline.withAlpha(0),
                  ),
                  collapsedShape: Border.all(
                    width: 0,
                    color: context.theme.colorScheme.outline.withAlpha(0),
                  ),
                  initiallyExpanded: true,
                  title: Text(
                    'Your feeds',
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  expansionAnimationStyle: AnimationStyle(
                    curve: Curves.easeOut,
                    duration: Durations.short3,
                  ),
                  children: _buildFeedTiles(state, context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildWallTiles(WallsState state, BuildContext context) {
    return [
      ...state.walls.map(
        (e) => Container(
          decoration: e.id == state.currentWall!.id
              ? BoxDecoration(
                  color: context.theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    UIConstants.tileItemBorderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 2,
                      spreadRadius: 0.1,
                      offset: const Offset(0.5, 0.5),
                    ),
                  ],
                )
              : null,
          child: ListTile(
            selected: e.id == state.currentWall!.id,
            selectedTileColor: context.theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UIConstants.tileItemBorderRadius,
              ),
            ),
            selectedColor: context.theme.colorScheme.primary,
            visualDensity: VisualDensity.compact,
            title: Text(
              e.name,
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.onSurface,
                fontWeight: e.id == state.currentWall!.id
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: state.pinnedWallId != null && e.id == state.pinnedWallId
                ? GestureDetector(
                    onTap: () {
                      context
                          .read<WallsBloc>()
                          .add(UnpinWallRequested(wallId: e.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 0),
                      child: Icon(
                        MingCute.pin_fill,
                        color:
                            context.theme.colorScheme.onSurface.withAlpha(217),
                      ),
                    ),
                  )
                : null,
            onTap: () {
              context.pop();
              context
                  .read<WallsBloc>()
                  .add(SelectWallRequested(selectedWall: e));
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildFeedTiles(WallsState state, BuildContext context) {
    List<Feed> feeds;
    try {
      feeds = state.walls.firstWhere((wall) => wall.isPrimary).feeds ?? [];
    } catch (e) {
      feeds = [];
    }
    return [
      ...feeds.map(
        (e) {
          String title = 'Feed';
          if (e.displayTitle != null && e.displayTitle!.isNotEmpty) {
            title = e.displayTitle!;
          } else if (e.title.isNotEmpty) {
            title = e.title.toTitleCase();
          }
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UIConstants.inputBorderRadius,
              ),
            ),
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text(
              title,
              style: context.theme.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            onTap: () async {
              final Map<String, Object> extra = {
                'feed': e,
                'isFollowed': true,
              };
              final unfollowed = await context.pushNamed(
                  RouteConstants.feedViewPageName,
                  pathParameters: {'feedId': e.id.toString()},
                  extra: extra);
              if ((unfollowed as bool) == true && context.mounted) {
                context
                    .read<WallsBloc>()
                    .add(ListWallsRequested(refreshItems: true));
              }
            },
          );
        },
      ),
    ];
  }
}
