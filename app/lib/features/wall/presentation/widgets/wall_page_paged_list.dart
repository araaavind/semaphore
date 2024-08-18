import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/wall/domain/entities/item.dart';
import 'package:app/features/wall/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/wall/presentation/widgets/item_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WallPagePagedList extends StatelessWidget {
  const WallPagePagedList({
    super.key,
    required PagingController<int, Item> pagingController,
    required RefreshController refreshController,
  })  : _pagingController = pagingController,
        _refreshController = refreshController;

  final PagingController<int, Item> _pagingController;
  final RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Refresher(
      controller: _refreshController,
      onRefresh: () async {
        _pagingController.refresh();
        context.read<WallsBloc>().add(ListWallsRequested());
      },
      child: CustomScrollView(
        slivers: [
          PagedSliverList<int, Item>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Item>(
              itemBuilder: (context, item, index) => ItemListTile(item: item),
              firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                title: TextConstants.itemListFetchErrorTitle,
                message: _pagingController.error,
                onTryAgain: () {
                  _pagingController.refresh();
                },
              ),
              newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                title: TextConstants.itemListFetchErrorTitle,
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
                padding:
                    EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
                child: ShimmerLoader(
                  pageSize: ServerConstants.defaultPaginationPageSize,
                ),
              ),
              noMoreItemsIndicatorBuilder: (_) => const NoMoreItemsIndicator(
                title: TextConstants.itemListEmptyMessageTitle,
                message: TextConstants.itemListEmptyMessageMessage,
              ),
              noItemsFoundIndicatorBuilder: (_) => const NoMoreItemsIndicator(
                title: TextConstants.itemListEmptyMessageTitle,
                message: TextConstants.itemListEmptyMessageMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
