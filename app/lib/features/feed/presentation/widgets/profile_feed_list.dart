import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/widgets/feed_list_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProfileFeedList extends StatefulWidget {
  const ProfileFeedList({super.key});

  @override
  State<ProfileFeedList> createState() => _ProfileFeedListState();
}

class _ProfileFeedListState extends State<ProfileFeedList> {
  final PagingController<int, FeedFollowsMap> _pagingController =
      PagingController(
    firstPageKey: 1,
    invisibleItemsThreshold: 1,
  );

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      context.read<SearchFeedBloc>().add(
            FeedSearchRequested(
              page: pageKey,
              pageSize: 100,
              type: ListFeedsType.followed,
            ),
          );
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchFeedBloc, SearchFeedState>(
      listener: (context, state) {
        if (state.status != SearchFeedStatus.loading) {
          _refreshController.refreshCompleted();
        }
        if (state.status == SearchFeedStatus.success) {
          var feedFollowsList = <FeedFollowsMap>[];
          for (var i = 0; i < state.feedList.feeds.length; i++) {
            feedFollowsList.add(
              FeedFollowsMap(
                feed: state.feedList.feeds[i],
                isFollowed: true,
              ),
            );
          }
          if (state.feedList.metadata.currentPage ==
              state.feedList.metadata.lastPage) {
            _pagingController.appendLastPage(feedFollowsList);
          } else {
            final nextPage = state.feedList.metadata.currentPage + 1;
            _pagingController.appendPage(feedFollowsList, nextPage);
          }
        } else if (state.status == SearchFeedStatus.failure) {
          _pagingController.error = state.message;
        }
      },
      child: Refresher(
        controller: _refreshController,
        onRefresh: () async => _pagingController.refresh(),
        child: PagedListView<int, FeedFollowsMap>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<FeedFollowsMap>(
            itemBuilder: (context, item, index) => FeedListTile(
              feedIsFollowedMap: item,
              pagingController: _pagingController,
              index: index,
            ),
            firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
              title: TextConstants.feedListFetchErrorTitle,
              message: _pagingController.error,
              onTryAgain: () {
                _pagingController.refresh();
              },
            ),
            newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
              title: TextConstants.feedListFetchErrorTitle,
              message: _pagingController.error,
              onTap: _pagingController.retryLastFailedRequest,
            ),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.pagePadding,
              ),
              child: ShimmerLoader(
                pageSize: 2,
                type: ShimmerLoaderType.lines,
              ),
            ),
            firstPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.pagePadding,
              ),
              child: ShimmerLoader(
                pageSize: ServerConstants.defaultPaginationPageSize,
                type: ShimmerLoaderType.lines,
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  TextConstants.feedListEmptyMessageTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 12.0),
        ),
      ),
    );
  }
}

class _FeedListTile extends StatelessWidget {
  final Feed feed;

  const _FeedListTile({required this.feed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.standard,
      title: Text(
        feed.title.isNotEmpty ? feed.title.toTitleCase() : 'Feed',
        style: context.theme.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: feed.description != null && feed.description!.isNotEmpty
          ? Text(
              feed.description!,
              style: context.theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
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
                Icons.rss_feed,
                size: 24,
                color: context.theme.colorScheme.primaryContainer,
              ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: UIConstants.tileContentPadding,
        horizontal: UIConstants.pagePadding,
      ),
      splashColor: Colors.transparent,
      onTap: () {
        final Map<String, Object> extra = {
          'feed': feed,
          'isFollowed': true,
        };
        context.pushNamed(
          RouteConstants.feedViewPageName,
          pathParameters: {'feedId': feed.id.toString()},
          extra: extra,
        );
      },
    );
  }
}
