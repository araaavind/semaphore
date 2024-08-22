import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/core/utils/string_casing_extension.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
        visualDensity: VisualDensity.standard,
        onTap: () {
          final Map<String, Object> extra = {
            'feed': feed,
            'followFeedBlocValue': BlocProvider.of<FollowFeedBloc>(context),
            'listItemsBlocValue': BlocProvider.of<ListItemsBloc>(context),
            'isFollowed': isFollowed,
          };
          context.go('/feeds/${feed.id}', extra: extra);
        },
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: UIConstants.tileContentPadding,
          horizontal: UIConstants.pagePadding,
        ),
        title: AutoSizeText(
          feed.title.toTitleCase(),
          style: context.theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          minFontSize: context.theme.textTheme.bodyLarge!.fontSize!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        horizontalTitleGap: UIConstants.tileHorizontalTitleGap,
        trailing: BlocConsumer<FollowFeedBloc, FollowFeedState>(
          listener: (context, state) {
            if (state.status == FollowFeedStatus.failure) {
              showSnackbar(context, state.message!);
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
            }
          },
          builder: (context, state) {
            if (state.status == FollowFeedStatus.loading &&
                state.feedId == feed.id) {
              return SizedBox(
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
              );
            }
            if (isFollowed) {
              return Container(
                height: 28.0,
                width: 28.0,
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    size: 28.0,
                    weight: 0.4,
                    color: context.theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    context.read<FollowFeedBloc>().add(
                          FollowUnfollowRequested(
                            feed.id,
                            action: FollowUnfollowAction.unfollow,
                          ),
                        );
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              );
            }
            return Container(
              height: 28.0,
              width: 28.0,
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 28.0,
                  weight: 0.4,
                  color: context.theme.colorScheme.onSurface,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.read<FollowFeedBloc>().add(
                        FollowUnfollowRequested(
                          feed.id,
                          action: FollowUnfollowAction.follow,
                        ),
                      );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
