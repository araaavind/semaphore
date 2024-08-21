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
      child: AppPagedList(
        pagingController: _pagingController,
        listType: PagedListType.list,
        itemBuilder: (context, item, index) => FeedListTile(
          feedIsFollowedMap: item,
          pagingController: _pagingController,
          index: index,
        ),
        firstPageErrorTitle: TextConstants.feedListFetchErrorTitle,
        newPageErrorTitle: TextConstants.feedListFetchErrorTitle,
        noMoreItemsErrorTitle: TextConstants.feedListEmptyMessageTitle,
        noMoreItemsErrorMessage: TextConstants.feedListEmptyMessageMessage,
        listEmptyErrorTitle: TextConstants.feedListEmptyMessageTitle,
        listEmptyErrorMessage: TextConstants.feedListEmptyMessageMessage,
      ),
    );
  }
}
