import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FeedListTile extends StatefulWidget {
  final FeedFollowsMap feedIsFollowedMap;
  final PagingController<int, FeedFollowsMap> _pagingController;
  final int _pageIndex;

  const FeedListTile({
    required this.feedIsFollowedMap,
    required PagingController<int, FeedFollowsMap> pagingController,
    required int index,
    super.key,
  })  : _pagingController = pagingController,
        _pageIndex = index;

  @override
  State<FeedListTile> createState() => _FeedListTileState();
}

class _FeedListTileState extends State<FeedListTile> {
  bool isFollowed = false;
  late final Feed feed;

  @override
  void initState() {
    super.initState();
    feed = widget.feedIsFollowedMap.feed;
    isFollowed = widget.feedIsFollowedMap.isFollowed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: UIConstants.borderWidth,
            color: context.theme.colorScheme.outline,
          ),
        ),
      ),
      child: ListTile(
        visualDensity: feed.description != null && feed.description!.isNotEmpty
            ? VisualDensity.standard
            : VisualDensity.compact,
        onTap: () {
          final Map<String, Object> extra = {
            'feed': feed,
            'followFeedBlocValue': BlocProvider.of<FollowFeedBloc>(context),
            'listItemsBlocValue': BlocProvider.of<ListItemsBloc>(context),
            'isFollowed': isFollowed,
          };
          context.goNamed(
            RouteConstants.feedViewPageName,
            pathParameters: {'feedId': feed.id.toString()},
            extra: extra,
          );
        },
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: UIConstants.tileContentPadding,
          horizontal: UIConstants.pagePadding,
        ),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6.0,
          children: [
            AutoSizeText(
              feed.title.isNotEmpty ? feed.title.toTitleCase() : 'Feed',
              style: context.theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: feed.description != null && feed.description!.isNotEmpty
            ? AutoSizeText(
                feed.description!,
                style: context.theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
                minFontSize: context.theme.textTheme.bodySmall!.fontSize!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        horizontalTitleGap: 10,
        leading: feed.imageUrl != null
            ? Container(
                width: 22.0,
                height: 22.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CachedNetworkImage(
                  imageUrl: feed.imageUrl ?? '',
                  fit: BoxFit.cover,
                  cacheKey: feed.imageUrl,
                  placeholder: (context, url) => Icon(
                    Icons.public,
                    size: 22.0,
                    color: context.theme.colorScheme.outline,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.public,
                    size: 22.0,
                    color: context.theme.colorScheme.outline,
                  ),
                ))
            : Icon(
                Icons.public,
                size: 22.0,
                color: context.theme.colorScheme.outline,
              ),
        trailing: BlocConsumer<FollowFeedBloc, FollowFeedState>(
          listener: (context, state) {
            if (state.status == FollowFeedStatus.failure) {
              showSnackbar(
                context,
                state.message!,
                type: SnackbarType.failure,
              );
            }
            if (state.feedId == feed.id &&
                (state.status == FollowFeedStatus.followed ||
                    state.status == FollowFeedStatus.unfollowed)) {
              setState(() {
                isFollowed = !isFollowed;
              });
              widget._pagingController.itemList![widget._pageIndex] =
                  FeedFollowsMap(
                feed: feed,
                isFollowed: isFollowed,
              );
              if (state.status == FollowFeedStatus.followed) {
                showSnackbar(
                  context,
                  'Followed ${feed.title}',
                  type: SnackbarType.utility,
                  actionLabel: 'Add to walls',
                  onActionPressed: () async {
                    final result = await context.pushNamed(
                      RouteConstants.addToWallPageName,
                      pathParameters: {'feedId': feed.id.toString()},
                      extra: {
                        'wallsBloc': BlocProvider.of<WallsBloc>(context),
                      },
                    );
                    if (result is Map<String, dynamic> &&
                        result['unfollow'] == true) {
                      if (context.mounted) {
                        context.read<FollowFeedBloc>().add(
                              FollowUnfollowRequested(
                                feed.id,
                                action: FollowUnfollowAction.unfollow,
                              ),
                            );
                      }
                    }
                  },
                );
              }
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: state.status == FollowFeedStatus.loading &&
                      state.feedId == feed.id
                  ? SizedBox(
                      height: 28.0,
                      width: 28.0,
                      child: isFollowed
                          ? SpinKitDualRing(
                              size: 21.0,
                              lineWidth: 3.0,
                              duration: const Duration(milliseconds: 400),
                              color: context.theme.colorScheme.onSurface,
                            )
                          : SpinKitHourGlass(
                              size: 23.0,
                              duration: const Duration(milliseconds: 2400),
                              color: context.theme.colorScheme.primary,
                            ),
                    )
                  : Container(
                      height: 28.0,
                      width: 28.0,
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isFollowed
                              ? Icon(
                                  MingCute.check_circle_fill,
                                  size: 28.0,
                                  weight: 0.4,
                                  color: context.theme.colorScheme.primary,
                                )
                              : Icon(
                                  MingCute.add_circle_line,
                                  size: 28.0,
                                  weight: 0.4,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                        ),
                        onPressed: isFollowed
                            ? () async {
                                final result = await context.pushNamed(
                                  RouteConstants.addToWallPageName,
                                  pathParameters: {
                                    'feedId': feed.id.toString()
                                  },
                                  extra: {
                                    'wallsBloc':
                                        BlocProvider.of<WallsBloc>(context),
                                  },
                                );
                                if (result is Map<String, dynamic> &&
                                    result['unfollow'] == true) {
                                  if (context.mounted) {
                                    context.read<FollowFeedBloc>().add(
                                          FollowUnfollowRequested(
                                            feed.id,
                                            action:
                                                FollowUnfollowAction.unfollow,
                                          ),
                                        );
                                  }
                                }
                              }
                            : () {
                                context.read<FollowFeedBloc>().add(
                                      FollowUnfollowRequested(
                                        feed.id,
                                        action: FollowUnfollowAction.follow,
                                      ),
                                    );
                              },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
