import 'package:app/core/common/widgets/refresher.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPagedList extends StatelessWidget {
  const SearchPagedList({
    super.key,
    required PagingController<int, Feed> pagingController,
    required RefreshController refreshController,
  })  : _pagingController = pagingController,
        _refreshController = refreshController;

  final PagingController<int, Feed> _pagingController;
  final RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Refresher(
      controller: _refreshController,
      onRefresh: () async => _pagingController.refresh(),
      child: PagedListView<int, Feed>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Feed>(
          itemBuilder: (context, item, index) => ListTile(
            title: Text(
              item.title,
              style: context.theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              item.description ?? '',
              style: context.theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
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
          newPageProgressIndicatorBuilder: (_) =>
              const ShimmerLoader(pageSize: 1),
          firstPageProgressIndicatorBuilder: (_) => const ShimmerLoader(
              pageSize: ServerConstants.defaultPaginationPageSize),
          noMoreItemsIndicatorBuilder: (_) => const NoMoreItemsIndicator(),
          noItemsFoundIndicatorBuilder: (_) => const NoMoreItemsIndicator(),
        ),
      ),
    );
  }
}
