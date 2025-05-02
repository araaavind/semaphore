import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/feed/presentation/cubit/wall/wall_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class WallPageDrawer extends StatelessWidget {
  final PagingController<int, Feed> _feedsPagingController;
  const WallPageDrawer({
    required PagingController<int, Feed> feedsPagingController,
    super.key,
  }) : _feedsPagingController = feedsPagingController;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 6.0,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      shadowColor: Colors.black.withAlpha(160),
      child: ListView(
        children: [
          ExpansionTile(
            childrenPadding: const EdgeInsets.all(8.0),
            trailing: GestureDetector(
              child: const Padding(
                padding: EdgeInsets.only(bottom: 2.0),
                child: Icon(
                  MingCute.add_fill,
                  size: 20,
                ),
              ),
              onTap: () async {
                final isCreated =
                    await context.pushNamed(RouteConstants.createWallPageName);
                if ((isCreated as bool) == true && context.mounted) {
                  context.read<WallsBloc>().add(ListWallsRequested());
                }
              },
            ),
            controlAffinity: ListTileControlAffinity.leading,
            expansionAnimationStyle: AnimationStyle(
              curve: Curves.easeOut,
              duration: Durations.short3,
            ),
            shape: Border(
              bottom: BorderSide(
                width: 1,
                color: context.theme.colorScheme.outline,
              ),
            ),
            collapsedShape: Border(
              bottom: BorderSide(
                width: 0,
                color: context.theme.colorScheme.outline.withOpacity(0),
              ),
            ),
            initiallyExpanded: true,
            title: Text(
              'Your walls',
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            children: [
              BlocListener<WallCubit, WallState>(
                listener: (context, state) {
                  if (state.status == WallStatus.success &&
                      (state.action == WallAction.pin ||
                          state.action == WallAction.unpin)) {
                    context.read<WallsBloc>().add(ListWallsRequested());
                  }
                },
                child: BlocBuilder<WallsBloc, WallsState>(
                  builder: (context, state) {
                    if (state.status == WallsStatus.initial) {
                      return const SizedBox.shrink();
                    }
                    if (state.status == WallsStatus.failure) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Unable to load walls'),
                      );
                    }
                    return Column(
                      children: [
                        ...state.walls.map(
                          (e) => Container(
                            decoration: e.id == state.currentWall!.id
                                ? BoxDecoration(
                                    color: context
                                        .theme.colorScheme.primaryContainer,
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
                              selectedTileColor:
                                  context.theme.colorScheme.primaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  UIConstants.tileItemBorderRadius,
                                ),
                              ),
                              selectedColor: context.theme.colorScheme.primary,
                              visualDensity: VisualDensity.compact,
                              title: Text(
                                e.name,
                                style: context.theme.textTheme.titleSmall
                                    ?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                  fontWeight: e.id == state.currentWall!.id
                                      ? FontWeight.w900
                                      : null,
                                ),
                              ),
                              trailing: e.isPinned
                                  ? GestureDetector(
                                      onTap: () {
                                        context
                                            .read<WallCubit>()
                                            .unpinWall(e.id);
                                      },
                                      child: Icon(
                                        MingCute.pin_fill,
                                        color: context
                                            .theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    )
                                  : e.isPrimary
                                      ? null
                                      : GestureDetector(
                                          onTap: () {
                                            context
                                                .read<WallCubit>()
                                                .pinWall(e.id);
                                          },
                                          child: Icon(
                                            MingCute.pin_line,
                                            color: context
                                                .theme.colorScheme.onSurface
                                                .withOpacity(0.3),
                                          ),
                                        ),
                              onTap: () {
                                context.pop();
                                context
                                    .read<WallsBloc>()
                                    .add(SelectWallRequested(selectedWall: e));
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
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
                context.goNamed('feeds');
              },
            ),
            controlAffinity: ListTileControlAffinity.leading,
            childrenPadding: const EdgeInsets.all(8.0),
            shape: Border.all(
              width: 0,
              color: context.theme.colorScheme.outline.withOpacity(0),
            ),
            collapsedShape: Border.all(
              width: 0,
              color: context.theme.colorScheme.outline.withOpacity(0),
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
            children: [
              DrawerFeedList(
                pagingController: _feedsPagingController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawerFeedList extends StatelessWidget {
  final PagingController<int, Feed> _pagingController;
  const DrawerFeedList({
    required PagingController<int, Feed> pagingController,
    super.key,
  }) : _pagingController = pagingController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchFeedBloc, SearchFeedState>(
      listener: (context, state) {
        if (state.status == SearchFeedStatus.success) {
          if (state.feedList.metadata.currentPage ==
              state.feedList.metadata.lastPage) {
            _pagingController.appendLastPage(state.feedList.feeds);
          } else {
            final nextPage = state.feedList.metadata.currentPage + 1;
            _pagingController.appendPage(state.feedList.feeds, nextPage);
          }
        } else if (state.status == SearchFeedStatus.failure) {
          _pagingController.error = state.message;
        }
      },
      child: AppPagedList(
        pagingController: _pagingController,
        listType: PagedListType.list,
        itemBuilder: (context, item, index) => ListTile(
          selectedTileColor: context.theme.colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              UIConstants.inputBorderRadius,
            ),
          ),
          selectedColor: context.theme.colorScheme.primary,
          visualDensity: VisualDensity.compact,
          title: Text(
            item.title.isNotEmpty ? item.title.toTitleCase() : 'Feed',
            style: context.theme.textTheme.titleSmall,
          ),
          onTap: () async {
            final Map<String, Object> extra = {
              'feed': item,
              'followFeedBlocValue': BlocProvider.of<FollowFeedBloc>(context),
              'listItemsBlocValue': BlocProvider.of<ListItemsBloc>(context),
              'isFollowed': true,
            };
            final unfollowed =
                await context.push('/feeds/${item.id}', extra: extra);
            if ((unfollowed as bool) == true) {
              _pagingController.refresh();
            }
          },
        ),
        showErrors: false,
        loaderType: PagedListLoaderType.circularProgressIndicator,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}
