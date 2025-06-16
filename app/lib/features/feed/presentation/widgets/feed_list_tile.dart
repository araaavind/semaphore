import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FeedListTile extends StatefulWidget {
  final FeedFollowsMap feedIsFollowedMap;
  final PagingController<int, FeedFollowsMap> _pagingController;
  final int _pageIndex;
  final Color? altPrimaryColor;

  const FeedListTile({
    required this.feedIsFollowedMap,
    required PagingController<int, FeedFollowsMap> pagingController,
    required int index,
    this.altPrimaryColor,
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
    String title = 'Feed';
    if (feed.displayTitle != null && feed.displayTitle!.isNotEmpty) {
      title = feed.displayTitle!;
    } else if (feed.title.isNotEmpty) {
      title = feed.title;
    }
    // Convert HTML to plain text
    final plainTextDescription = HtmlUtils.htmlToPlainText(feed.description);
    return ListTile(
      visualDensity: VisualDensity.standard,
      onTap: () {
        final Map<String, Object> extra = {
          'feed': feed,
          'isFollowed': isFollowed,
        };
        context.pushNamed(
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
            title,
            style: context.theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w600,
            ),
            minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      subtitle: plainTextDescription.isNotEmpty
          ? AutoSizeText(
              plainTextDescription,
              style: context.theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w300,
              ),
              minFontSize: context.theme.textTheme.bodySmall!.fontSize!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      horizontalTitleGap: UIConstants.tileHorizontalTitleGap,
      leading: Container(
        width: 36.0,
        height: 36.0,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 1,
              spreadRadius: 0,
              offset: const Offset(0.2, 0.2),
            ),
          ],
        ),
        child: feed.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: feed.imageUrl ?? '',
                fit: BoxFit.contain,
                cacheKey: feed.imageUrl,
                memCacheWidth: 36,
                maxWidthDiskCache: 36,
                errorListener: (e) {
                  if (kDebugMode) {
                    print('Error loading image: $e');
                  }
                },
                placeholder: (context, url) => Icon(
                  Icons.public,
                  size: 24,
                  color: context.theme.colorScheme.primaryContainer,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.public,
                  size: 24,
                  color: context.theme.colorScheme.primaryContainer,
                ),
              )
            : Icon(
                MingCute.rss_2_line,
                size: 24,
                color: context.theme.colorScheme.primaryContainer,
              ),
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
            if (state.status == FollowFeedStatus.unfollowed) {
              context.read<WallsBloc>().add(
                    ListWallsRequested(
                      refreshItems: true,
                    ),
                  );
            }
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
                  );
                  if (result is Map<String, dynamic> && context.mounted) {
                    if (result['unfollow'] == true) {
                      context.read<FollowFeedBloc>().add(
                            FollowUnfollowRequested(
                              feed.id,
                              action: FollowUnfollowAction.unfollow,
                            ),
                          );
                    }
                    if (result['listUpdated'] == true) {
                      context.read<WallsBloc>().add(
                            ListWallsRequested(
                              refreshItems: true,
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
                            color: widget.altPrimaryColor ??
                                context.theme.colorScheme.primary,
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
                                MdiIcons.checkboxMarkedCirclePlusOutline,
                                size: 27.0,
                                weight: 0.4,
                                color: widget.altPrimaryColor != null
                                    ? HSLColor.fromColor(
                                            widget.altPrimaryColor!)
                                        .withAlpha(0.6)
                                        .toColor()
                                    : context.theme.colorScheme.primary,
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
                                pathParameters: {'feedId': feed.id.toString()},
                              );
                              if (result is Map<String, dynamic> &&
                                  context.mounted) {
                                if (result['unfollow'] == true) {
                                  context.read<FollowFeedBloc>().add(
                                        FollowUnfollowRequested(
                                          feed.id,
                                          action: FollowUnfollowAction.unfollow,
                                        ),
                                      );
                                }
                                if (result['listUpdated'] == true) {
                                  context.read<WallsBloc>().add(
                                        ListWallsRequested(
                                          refreshItems: true,
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
    );
  }
}
