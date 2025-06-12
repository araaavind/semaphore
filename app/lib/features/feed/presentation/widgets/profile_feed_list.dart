import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/widgets/feed_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProfileFeedList extends StatefulWidget {
  const ProfileFeedList({super.key});

  @override
  State<ProfileFeedList> createState() => _ProfileFeedListState();
}

class _ProfileFeedListState extends State<ProfileFeedList>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pagingController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                type: ShimmerLoaderType.feedmag,
              ),
            ),
            firstPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.pagePadding,
              ),
              child: ShimmerLoader(
                pageSize: ServerConstants.defaultPaginationPageSize,
                type: ShimmerLoaderType.feedmag,
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
