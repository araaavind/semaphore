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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:ui' as ui;

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
    String title = 'Feed';
    if (widget.feed.displayTitle != null &&
        widget.feed.displayTitle!.isNotEmpty) {
      title = widget.feed.displayTitle!;
    } else if (widget.feed.title.isNotEmpty) {
      title = widget.feed.title;
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
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
                                  width: 36.0,
                                  height: 36.0,
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
                                    color: context.theme.colorScheme.onSurface,
                                  ),
                                  child: CachedNetworkImage(
                                    height: 36.0,
                                    width: 36.0,
                                    imageUrl: feed.imageUrl ?? '',
                                    fit: BoxFit.contain,
                                    cacheKey: feed.imageUrl,
                                    placeholder: (context, url) => Icon(
                                      Icons.public,
                                      size: 24,
                                      color: context
                                          .theme.colorScheme.primaryContainer,
                                    ),
                                    errorListener: (e) {
                                      if (kDebugMode) {
                                        print('Error loading image: $e');
                                      }
                                    },
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.public,
                                      size: 24,
                                      color: context
                                          .theme.colorScheme.primaryContainer,
                                    ),
                                  ),
                                ),
                              if (feed.imageUrl != null)
                                const SizedBox(width: 16.0),
                              Expanded(
                                child: AutoSizeText(
                                  title,
                                  style: context.theme.textTheme.displaySmall
                                      ?.copyWith(
                                    fontSize: 26,
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
                              child: ExpandableDescription(
                                description: widget.feed.description ?? '',
                                style: context.theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          SelectableText(
                            widget.feed.link,
                            style:
                                context.theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: context.theme.colorScheme.tertiary
                                  .withAlpha(204),
                              decoration: TextDecoration.underline,
                            ),
                            enableInteractiveSelection: true,
                            maxLines: 2,
                            onSelectionChanged: (selection, cause) {
                              if (cause == SelectionChangedCause.tap) {
                                launchUrlInBrowser(widget.feed.link);
                              }
                            },
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
                                if (state.status ==
                                    FollowFeedStatus.unfollowed) {
                                  context.read<WallsBloc>().add(
                                        ListWallsRequested(
                                          refreshItems: true,
                                        ),
                                      );
                                }
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
  final PagingController<String, Item> _pagingController = PagingController(
    firstPageKey: '',
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
                after: pageKey,
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
          if (state.itemList.metadata.nextCursor == '' &&
              state.itemList.metadata.hasMore == false) {
            _pagingController.appendLastPage(state.itemList.items);
          } else {
            _pagingController.appendPage(
              state.itemList.items,
              state.itemList.metadata.nextCursor,
            );
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
            AppPagedList<String, Item>(
              pagingController: _pagingController,
              listType: PagedListType.sliverList,
              shimmerLoaderType: ShimmerLoaderType.magazine,
              itemBuilder: (context, item, index) => ItemListTileMag(
                item: item,
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

class ExpandableDescription extends StatefulWidget {
  final String description;
  final TextStyle? style;
  final int maxLines;

  const ExpandableDescription({
    super.key,
    required this.description,
    this.style,
    this.maxLines = 5,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;
  bool isOverflowing = false;

  @override
  Widget build(BuildContext context) {
    // Convert HTML to plain text
    final plainTextDescription = HtmlUtils.htmlToPlainText(widget.description);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Create a TextPainter to measure if text overflows
        final textPainter = TextPainter(
          text: TextSpan(
            text: plainTextDescription,
            style: widget.style,
          ),
          maxLines: widget.maxLines,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final textOverflows = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Text(
                  plainTextDescription,
                  style: widget.style,
                  maxLines: isExpanded ? null : widget.maxLines,
                  overflow: isExpanded ? null : TextOverflow.clip,
                  textDirection: ui.TextDirection.ltr,
                ),
                if (textOverflows && !isExpanded)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: (widget.style?.fontSize ?? 16) * 1.5,
                      width: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: const [0.0, 0.5],
                          colors: [
                            context.theme.colorScheme.surface.withAlpha(0),
                            context.theme.colorScheme.surface,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Text(
                              isExpanded ? 'Show less' : 'Show more',
                              style:
                                  context.theme.textTheme.bodyMedium?.copyWith(
                                color: context.theme.colorScheme.onSurface
                                    .withAlpha(200),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (textOverflows && isExpanded)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Text(
                      'Show less',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color:
                            context.theme.colorScheme.onSurface.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
          ],
        );
      },
    );
  }
}
