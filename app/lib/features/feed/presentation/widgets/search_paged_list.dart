import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'feed_list_tile.dart';

class SearchPagedList extends StatelessWidget {
  const SearchPagedList({
    super.key,
    required PagingController<int, FeedFollowsMap> pagingController,
    required RefreshController refreshController,
  })  : _pagingController = pagingController,
        _refreshController = refreshController;

  final PagingController<int, FeedFollowsMap> _pagingController;
  final RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Refresher(
      controller: _refreshController,
      onRefresh: () async => _pagingController.refresh(),
      child: PagedListView<int, FeedFollowsMap>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<FeedFollowsMap>(
          itemBuilder: (context, item, index) => FeedListTile(
            pagingController: _pagingController,
            index: index,
            feedIsFollowedMap: item,
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
            child: ShimmerLoader(pageSize: 2),
          ),
          firstPageProgressIndicatorBuilder: (_) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
            child: ShimmerLoader(
              pageSize: ServerConstants.defaultPaginationPageSize,
            ),
          ),
          noMoreItemsIndicatorBuilder: (_) => const NoMoreItemsIndicator(),
          noItemsFoundIndicatorBuilder: (_) => const NoMoreItemsIndicator(),
        ),
      ),
    );
  }
}
