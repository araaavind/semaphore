import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/item.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/core/common/cubits/scroll_to_top/scroll_to_top_cubit.dart';
import 'package:app/features/feed/presentation/widgets/item_list_tile_card.dart';
import 'package:app/features/feed/presentation/widgets/item_list_tile_mag.dart';
import 'package:app/features/feed/presentation/widgets/wall_page_drawer.dart';
import 'package:app/features/feed/presentation/widgets/wall_page_sliver_app_bar.dart';
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

  ShimmerLoaderType _shimmerLoaderType = ShimmerLoaderType.text;

  final ScrollController _scrollController = ScrollController();

  void _setShimmerLoaderType(WallViewOption wallView) {
    setState(() {
      switch (wallView) {
        case WallViewOption.card:
          _shimmerLoaderType = ShimmerLoaderType.card;
          break;
        case WallViewOption.text:
          _shimmerLoaderType = ShimmerLoaderType.text;
          break;
        case WallViewOption.magazine:
        default:
          _shimmerLoaderType = ShimmerLoaderType.magazine;
          break;
      }
    });
  }

  void _scrollToTop({required bool animate}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      } else {
        _scrollController.jumpTo(0);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          if (animate) {
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          } else {
            _scrollController.jumpTo(0);
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        final currentWall = context.read<WallsBloc>().state.currentWall;
        if (currentWall != null) {
          context.read<ListItemsBloc>().add(
                ListItemsRequested(
                  parentId: currentWall.id,
                  parentType: ListItemsParentType.wall,
                  page: pageKey,
                  pageSize: ServerConstants.defaultPaginationPageSize,
                ),
              );
        }
      },
    );

    // Set initial shimmer loader type
    final currentWallView = context.read<WallsBloc>().state.wallView;
    _setShimmerLoaderType(currentWallView);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const WallPageDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.60,
      drawerScrimColor:
          context.theme.colorScheme.surfaceContainer.withAlpha(180),
      body: BlocConsumer<WallsBloc, WallsState>(
        listener: (context, state) {
          if (state.status == WallStatus.success &&
              state.action == WallAction.create) {
            context.read<WallsBloc>().add(ListWallsRequested());
            return;
          } else if (state.status == WallStatus.success &&
              state.action == WallAction.delete) {
            // Select the primary wall to navigate back to
            final walls = context.read<WallsBloc>().state.walls;
            Wall? pinnedWall;
            try {
              pinnedWall = walls.firstWhere((element) => element.isPinned);
            } catch (e) {
              pinnedWall = null;
            }
            context.read<WallsBloc>().add(
                  SelectWallRequested(
                    selectedWall: pinnedWall ??
                        walls.firstWhere((element) => element.isPrimary),
                  ),
                );
            context.read<WallsBloc>().add(ListWallsRequested());
            return;
          } else if (state.status == WallStatus.success &&
              state.action == WallAction.update) {
            context.read<WallsBloc>().add(ListWallsRequested());
            return;
          } else if (state.status == WallStatus.success &&
              (state.action == WallAction.pin ||
                  state.action == WallAction.unpin)) {
            context.read<WallsBloc>().add(ListWallsRequested());
            return;
          }

          if (state.status == WallStatus.failure) {
            showSnackbar(context, state.message!, type: SnackbarType.failure);
            return;
          }

          if (state.status == WallStatus.success &&
              ((state.action == WallAction.select ||
                      state.action == WallAction.changeFilter) ||
                  (state.action == WallAction.list &&
                      state.refreshItems == true))) {
            _pagingController.refresh();
            _setShimmerLoaderType(state.wallView);
            _scrollToTop(animate: false);
          }
        },
        buildWhen: (previous, current) {
          return (current.status == WallStatus.success &&
                  current.action == WallAction.list &&
                  current.refreshItems == true) ||
              current.action == WallAction.changeFilter;
        },
        builder: (context, state) {
          return BlocListener<ScrollToTopCubit, bool>(
            listener: (context, state) {
              if (state) {
                _scrollToTop(animate: true);
                context.read<ScrollToTopCubit>().scrollToTopCompleted();
              }
            },
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                const WallPageSliverAppBar(),
              ],
              body: Builder(
                builder: (context) {
                  if (state.status == WallStatus.loading ||
                      state.currentWall == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.pagePadding,
                      ),
                      child: ShimmerLoader(
                        pageSize: 12,
                        type: _shimmerLoaderType,
                      ),
                    );
                  }
                  return BlocListener<ListItemsBloc, ListItemsState>(
                    listener: (context, state) {
                      if (state.status != ListItemsStatus.loading) {
                        _refreshController.refreshCompleted();
                      }
                      if (state.status == ListItemsStatus.success) {
                        if (state.itemList.metadata.currentPage ==
                            state.itemList.metadata.lastPage) {
                          _pagingController
                              .appendLastPage(state.itemList.items);
                        } else {
                          final nextPage =
                              state.itemList.metadata.currentPage + 1;
                          _pagingController.appendPage(
                              state.itemList.items, nextPage);
                        }
                      } else if (state.status == ListItemsStatus.failure) {
                        _pagingController.error = state.message;
                      }
                    },
                    child: Refresher(
                      controller: _refreshController,
                      onRefresh: () async {
                        _pagingController.refresh();
                      },
                      child: CustomScrollView(
                        cacheExtent: 500,
                        slivers: [
                          AppPagedList<Item>(
                            pagingController: _pagingController,
                            listType: PagedListType.sliverList,
                            itemBuilder: (context, item, index) =>
                                state.wallView == WallViewOption.card
                                    ? ItemListTileCard(
                                        item: item,
                                        pagingController: _pagingController,
                                      )
                                    : ItemListTileMag(
                                        item: item,
                                        pagingController: _pagingController,
                                        isTextOnly: state.wallView ==
                                            WallViewOption.text,
                                      ),
                            shimmerLoaderType: _shimmerLoaderType,
                            firstPageErrorTitle:
                                TextConstants.itemListFetchErrorTitle,
                            newPageErrorTitle:
                                TextConstants.itemListFetchErrorTitle,
                            noMoreItemsErrorTitle:
                                TextConstants.itemListNoMoreItemsErrorTitle,
                            noMoreItemsErrorMessage:
                                TextConstants.itemListNoMoreItemsErrorMessage,
                            listEmptyErrorTitle:
                                TextConstants.itemListEmptyMessageTitle,
                            listEmptyErrorMessage:
                                TextConstants.itemListEmptyFollowMessageMessage,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
