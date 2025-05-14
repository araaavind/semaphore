import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

enum PagedListType { sliverList, list }

enum PagedListLoaderType { circularProgressIndicator, shimmerIndicator }

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
    this.showErrors = true,
    this.loaderType = PagedListLoaderType.shimmerIndicator,
    this.shimmerLoaderType = ShimmerLoaderType.text,
    this.shrinkWrap = false,
    this.shimmerHorizontalPadding,
    this.physics,
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
  final bool showErrors;
  final PagedListLoaderType loaderType;
  final ShimmerLoaderType shimmerLoaderType;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? shimmerHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (listType == PagedListType.list) {
      return PagedListView(
        pagingController: _pagingController,
        builderDelegate: appPagedChildBuilderDelegate(),
        shrinkWrap: shrinkWrap,
        physics: this.physics,
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
      firstPageErrorIndicatorBuilder: this.showErrors
          ? (_) => FirstPageErrorIndicator(
                title: this.firstPageErrorTitle,
                message: _pagingController.error,
                onTryAgain: () {
                  _pagingController.refresh();
                },
              )
          : null,
      newPageErrorIndicatorBuilder: this.showErrors
          ? (_) => NewPageErrorIndicator(
                title: this.newPageErrorTitle,
                message: _pagingController.error,
                onTap: _pagingController.retryLastFailedRequest,
              )
          : null,
      newPageProgressIndicatorBuilder: this.loaderType ==
              PagedListLoaderType.shimmerIndicator
          ? (_) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      this.shimmerHorizontalPadding ?? UIConstants.pagePadding,
                ),
                child: ShimmerLoader(
                  pageSize: 2,
                  type: shimmerLoaderType,
                ),
              )
          : null,
      firstPageProgressIndicatorBuilder: this.loaderType ==
              PagedListLoaderType.shimmerIndicator
          ? (_) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      this.shimmerHorizontalPadding ?? UIConstants.pagePadding,
                ),
                child: ShimmerLoader(
                  pageSize: ServerConstants.defaultPaginationPageSize,
                  type: shimmerLoaderType,
                ),
              )
          : null,
      noMoreItemsIndicatorBuilder: this.showErrors
          ? (_) => NoMoreItemsIndicator(
                title: this.noMoreItemsErrorTitle,
                message: this.noMoreItemsErrorMessage,
              )
          : null,
      noItemsFoundIndicatorBuilder: this.showErrors
          ? (_) => NoMoreItemsIndicator(
                title: this.listEmptyErrorTitle,
                message: this.listEmptyErrorMessage,
              )
          : null,
    );
  }
}
