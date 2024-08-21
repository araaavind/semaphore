import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

enum PagedListType { sliverList, list }

typedef ItemWidgetBuilder<ItemType> = Widget Function(
  BuildContext context,
  ItemType item,
  int index,
);

class AppPagedList<ItemType> extends StatelessWidget {
  const AppPagedList({
    super.key,
    required PagingController<int, ItemType> pagingController,
    required this.listType,
    required this.itemBuilder,
    this.firstPageErrorTitle = 'Failed to load items',
    this.newPageErrorTitle = 'Failed to load items',
    this.noMoreItemsErrorTitle = 'Nothing to see here',
    this.noMoreItemsErrorMessage = 'Try again later',
    this.listEmptyErrorTitle = 'Nothing to see here',
    this.listEmptyErrorMessage = 'Try again later',
  }) : _pagingController = pagingController;

  final PagingController<int, ItemType> _pagingController;
  final PagedListType listType;
  final ItemWidgetBuilder<ItemType> itemBuilder;
  final String firstPageErrorTitle;
  final String newPageErrorTitle;
  final String noMoreItemsErrorTitle;
  final String noMoreItemsErrorMessage;
  final String listEmptyErrorTitle;
  final String listEmptyErrorMessage;

  @override
  Widget build(BuildContext context) {
    if (listType == PagedListType.list) {
      return PagedListView(
        pagingController: _pagingController,
        builderDelegate: appPagedChildBuilderDelegate(),
      );
    }
    return PagedSliverList<int, ItemType>(
      pagingController: _pagingController,
      builderDelegate: appPagedChildBuilderDelegate(),
    );
  }

  PagedChildBuilderDelegate<ItemType> appPagedChildBuilderDelegate() {
    return PagedChildBuilderDelegate<ItemType>(
      itemBuilder: itemBuilder,
      firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
        title: this.firstPageErrorTitle,
        message: _pagingController.error,
        onTryAgain: () {
          _pagingController.refresh();
        },
      ),
      newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
        title: this.newPageErrorTitle,
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
      noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(
        title: this.noMoreItemsErrorTitle,
        message: this.noMoreItemsErrorMessage,
      ),
      noItemsFoundIndicatorBuilder: (_) => NoMoreItemsIndicator(
        title: this.listEmptyErrorTitle,
        message: this.listEmptyErrorMessage,
      ),
    );
  }
}
