import 'package:app/core/constants/constants.dart';
import 'package:app/features/wall/domain/entities/item.dart';
import 'package:app/features/wall/presentation/bloc/list_items_bloc.dart';
import 'package:app/features/wall/presentation/widgets/wall_page_paged_list.dart';
import 'package:app/features/wall/presentation/widgets/wall_page_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WallPage extends StatefulWidget {
  const WallPage({super.key});

  @override
  State<WallPage> createState() => _WallPageState();
}

class _WallPageState extends State<WallPage> {
  final PagingController<int, Item> _pagingController = PagingController(
    firstPageKey: 1,
    // invisibleItemsThreshold will determine how many items should be loaded
    // after the first page is loaded (if the first page does not fill the
    // screen, items enough to fill the page will be loaded anyway unless
    // invisibleItemsThreshold is set to 0).
    invisibleItemsThreshold: 1,
  );

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        context.read<ListItemsBloc>().add(
              ListItemsRequested(
                wallId: 1,
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
              ),
            );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const WallPageSliverAppBar(),
        ],
        body: BlocListener<ListItemsBloc, ListItemsState>(
          listener: (context, state) {
            if (state.status != ListItemsStatus.loading) {
              _refreshController.refreshCompleted();
            }
            if (state.status == ListItemsStatus.success) {
              if (state.itemList.metadata.currentPage ==
                  state.itemList.metadata.lastPage) {
                _pagingController.appendLastPage(state.itemList.items);
              } else {
                final nextPage = state.itemList.metadata.currentPage + 1;
                _pagingController.appendPage(state.itemList.items, nextPage);
              }
            } else if (state.status == ListItemsStatus.failure) {
              _pagingController.error = state.message;
            }
          },
          child: WallPagePagedList(
            pagingController: _pagingController,
            refreshController: _refreshController,
          ),
        ),
      ),
    );
  }
}
