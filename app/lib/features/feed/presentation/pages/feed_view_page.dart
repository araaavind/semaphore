import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_followers/list_followers_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/feed/presentation/widgets/followers_count.dart';
import 'package:app/features/feed/presentation/widgets/item_list_tile_mag.dart';
import 'package:app/init_dependencies.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedViewPage extends StatefulWidget {
  final Feed feed;
  final bool isFollowed;
  const FeedViewPage({
    super.key,
    required this.feed,
    required this.isFollowed,
  });

  @override
  State<FeedViewPage> createState() => _FeedViewPageState();
}

class _FeedViewPageState extends State<FeedViewPage> {
  bool isFollowed = false;
  late final Feed feed;

  @override
  void initState() {
    super.initState();
    feed = widget.feed;
    isFollowed = widget.isFollowed;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.pop(!isFollowed);
      },
      child: Scaffold(
        appBar: AppBar(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.pagePadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (feed.imageUrl != null)
                                Container(
                                  width: 64.0,
                                  height: 64.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(25),
                                        blurRadius: 1,
                                        spreadRadius: 0,
                                        offset: const Offset(0.2, 0.2),
                                      ),
                                    ],
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: feed.imageUrl ?? '',
                                    fit: BoxFit.contain,
                                    cacheKey: feed.imageUrl,
                                    placeholder: (context, url) => Icon(
                                      Icons.public,
                                      size: 24,
                                      color: context
                                          .theme.colorScheme.primaryContainer,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.public,
                                      size: 24,
                                      color: context
                                          .theme.colorScheme.primaryContainer,
                                    ),
                                  ),
                                ),
                              if (feed.imageUrl != null)
                                const SizedBox(width: 18.0),
                              Expanded(
                                child: AutoSizeText(
                                  widget.feed.title.isNotEmpty
                                      ? widget.feed.title.toTitleCase()
                                      : 'Feed',
                                  style: context.theme.textTheme.displaySmall
                                      ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 4,
                                  minFontSize: context
                                      .theme.textTheme.titleMedium!.fontSize!,
                                ),
                              ),
                            ],
                          ),
                          if (feed.description != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                widget.feed.description ?? '',
                                style: context.theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          SelectableText(
                            widget.feed.feedLink,
                            style:
                                context.theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: context.theme.colorScheme.onSurface
                                  .withOpacity(0.8),
                            ),
                            enableInteractiveSelection: true,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12.0),
                          BlocProvider(
                            create: (context) =>
                                serviceLocator<ListFollowersBloc>(),
                            child: FollowersCount(feed: feed),
                          ),
                          const SizedBox(height: 12.0),
                          BlocConsumer<FollowFeedBloc, FollowFeedState>(
                            listener: (context, state) {
                              if (state.status == FollowFeedStatus.failure) {
                                showSnackbar(
                                  context,
                                  state.message!,
                                  type: SnackbarType.failure,
                                );
                              }
                              if (state.feedId == widget.feed.id &&
                                  (state.status == FollowFeedStatus.followed ||
                                      state.status ==
                                          FollowFeedStatus.unfollowed)) {
                                setState(() {
                                  isFollowed = !isFollowed;
                                });
                              }
                            },
                            builder: (context, state) {
                              var buttonText = 'Follow';
                              var action = FollowUnfollowAction.follow;
                              if (isFollowed) {
                                buttonText = 'Unfollow';
                                action = FollowUnfollowAction.unfollow;
                              }
                              return isFollowed
                                  ? Row(
                                      children: [
                                        Flexible(
                                          child: Button(
                                            text: buttonText,
                                            textColor: context
                                                .theme.colorScheme.onSurface,
                                            width: double.infinity,
                                            filled: !isFollowed,
                                            onPressed: () {
                                              context
                                                  .read<FollowFeedBloc>()
                                                  .add(
                                                    FollowUnfollowRequested(
                                                      feed.id,
                                                      action: action,
                                                    ),
                                                  );
                                            },
                                            isLoading: state.feedId ==
                                                    feed.id &&
                                                state.status ==
                                                    FollowFeedStatus.loading,
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Flexible(
                                          child: Button(
                                            text: 'Add to walls',
                                            width: double.infinity,
                                            filled: true,
                                            onPressed: () async {
                                              final result =
                                                  await context.pushNamed(
                                                RouteConstants
                                                    .addToWallPageName,
                                                pathParameters: {
                                                  'feedId': feed.id.toString()
                                                },
                                              );
                                              if (result
                                                      is Map<String, dynamic> &&
                                                  context.mounted) {
                                                if (result['unfollow'] ==
                                                    true) {
                                                  context
                                                      .read<FollowFeedBloc>()
                                                      .add(
                                                        FollowUnfollowRequested(
                                                          feed.id,
                                                          action:
                                                              FollowUnfollowAction
                                                                  .unfollow,
                                                        ),
                                                      );
                                                }
                                                if (result['listUpdated'] ==
                                                    true) {
                                                  context.read<WallsBloc>().add(
                                                        ListWallsRequested(
                                                          refreshItems: true,
                                                        ),
                                                      );
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Button(
                                      text: buttonText,
                                      filled: !isFollowed,
                                      width: double.infinity,
                                      onPressed: () {
                                        context.read<FollowFeedBloc>().add(
                                              FollowUnfollowRequested(
                                                feed.id,
                                                action: action,
                                              ),
                                            );
                                      },
                                      isLoading: state.feedId == feed.id &&
                                          state.status ==
                                              FollowFeedStatus.loading,
                                    );
                            },
                          ),
                          const SizedBox(height: 16.0),
                          if (feed.pubUpdated != null)
                            Text(
                              'Last published on ${DateFormat('d MMM, yyyy').format(feed.pubUpdated!)}',
                              style:
                                  context.theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: FeedViewItems(feedId: feed.id),
        ),
      ),
    );
  }
}

class FeedViewItems extends StatefulWidget {
  final int feedId;
  const FeedViewItems({
    super.key,
    required this.feedId,
  });

  @override
  State<FeedViewItems> createState() => _FeedViewItemsState();
}

class _FeedViewItemsState extends State<FeedViewItems> {
  final PagingController<int, Item> _pagingController = PagingController(
    firstPageKey: 1,
    // invisibleItemsThreshold will determine how many items should be loaded
    // after the first page is loaded (if the first page does not fill the
    // screen, items enough to fill the page will be loaded anyway unless
    // invisibleItemsThreshold is set to 0).
    invisibleItemsThreshold: 1,
  );

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        context.read<ListItemsBloc>().add(
              ListItemsRequested(
                parentId: widget.feedId,
                parentType: ListItemsParentType.feed,
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
              ),
            );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListItemsBloc, ListItemsState>(
      listener: (context, state) {
        if (state.status != ListItemsStatus.loading) {
          _refreshController.refreshCompleted();
        }
        if (state.status == ListItemsStatus.success) {
          if (state.itemList.metadata.currentPage ==
              state.itemList.metadata.lastPage) {
            _pagingController.appendLastPage(state.itemList.items);
          } else {
            final nextPage = state.itemList.metadata.currentPage + 1;
            _pagingController.appendPage(state.itemList.items, nextPage);
          }
        } else if (state.status == ListItemsStatus.failure) {
          _pagingController.error = state.message;
        }
      },
      child: Refresher(
        controller: _refreshController,
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: CustomScrollView(
          cacheExtent: 500,
          slivers: [
            AppPagedList<Item>(
              pagingController: _pagingController,
              listType: PagedListType.sliverList,
              shimmerLoaderType: ShimmerLoaderType.magazine,
              itemBuilder: (context, item, index) => ItemListTileMag(
                item: item,
                pagingController: _pagingController,
              ),
              firstPageErrorTitle: TextConstants.itemListFetchErrorTitle,
              newPageErrorTitle: TextConstants.itemListFetchErrorTitle,
              noMoreItemsErrorTitle:
                  TextConstants.itemListNoMoreItemsErrorTitle,
              noMoreItemsErrorMessage:
                  TextConstants.itemListNoMoreItemsErrorMessage,
              listEmptyErrorTitle: TextConstants.itemListEmptyMessageTitle,
              listEmptyErrorMessage: TextConstants.itemListEmptyMessageMessage,
            ),
          ],
        ),
      ),
    );
  }
}
