import 'package:app/core/common/cubits/network/network_cubit.dart';
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
import 'package:app/features/feed/presentation/widgets/item_list_tile_text.dart';
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
  bool _isCollapsed = false;
  final ScrollController _scrollController = ScrollController();

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

    final wallState = context.read<WallsBloc>().state;
    if (wallState.status == WallStatus.initial) {
      context.read<WallsBloc>().add(ListWallsRequested(refreshItems: true));
    }

    _scrollController.addListener(() {
      if (_scrollController.offset > kToolbarHeight / 2) {
        setState(() {
          _isCollapsed = true;
        });
      } else {
        setState(() {
          _isCollapsed = false;
        });
      }
    });
  }

  @override
  void dispose() {
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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          WallPageSliverAppBar(isCollapsed: _isCollapsed),
        ],
        body: MultiBlocListener(
          listeners: [
            BlocListener<ScrollToTopCubit, bool>(
              listener: (context, state) {
                if (state) {
                  _scrollToTop(animate: true);
                  context.read<ScrollToTopCubit>().scrollToTopCompleted();
                }
              },
            ),
            BlocListener<NetworkCubit, NetworkState>(
              listener: (context, state) {
                if (state.status == NetworkStatus.connected &&
                    context.read<WallsBloc>().state.currentWall == null) {
                  context
                      .read<WallsBloc>()
                      .add(ListWallsRequested(refreshItems: true));
                }
              },
            ),
          ],
          child: BlocConsumer<WallsBloc, WallsState>(
            listener: (context, state) {
              if (state.status == WallStatus.success &&
                  state.action == WallAction.create) {
                context
                    .read<WallsBloc>()
                    .add(ListWallsRequested(refreshItems: false));
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
                context
                    .read<WallsBloc>()
                    .add(ListWallsRequested(refreshItems: false));
                return;
              } else if (state.status == WallStatus.success &&
                  state.action == WallAction.update) {
                context
                    .read<WallsBloc>()
                    .add(ListWallsRequested(refreshItems: false));
                return;
              } else if (state.status == WallStatus.success &&
                  (state.action == WallAction.pin ||
                      state.action == WallAction.unpin)) {
                context
                    .read<WallsBloc>()
                    .add(ListWallsRequested(refreshItems: false));
                return;
              }

              // rebuild content for the following actions
              if (state.status == WallStatus.success &&
                  (state.action == WallAction.select ||
                      state.action == WallAction.changeFilter)) {
                context
                    .read<WallsBloc>()
                    .add(ListWallsRequested(refreshItems: true));
              }

              if (state.status == WallStatus.failure) {
                showSnackbar(context, state.message!,
                    type: SnackbarType.failure);
                return;
              }
            },
            buildWhen: (previous, current) {
              return previous != current &&
                  current.action == WallAction.list &&
                  current.refreshItems == true;
            },
            builder: (context, state) {
              if (state.status == WallStatus.loading) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: Loader(),
                  ),
                );
              }
              if (state.status == WallStatus.failure &&
                  state.action == WallAction.list) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Unable to load posts.\nCheck your internet connection or try again later.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (state.currentWall == null) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(child: Loader()),
                );
              }
              return const _WallPageItems();
            },
          ),
        ),
      ),
    );
  }
}

class _WallPageItems extends StatefulWidget {
  const _WallPageItems();

  @override
  State<_WallPageItems> createState() => __WallPageItemsState();
}

class __WallPageItemsState extends State<_WallPageItems> {
  final PagingController<String, Item> _pagingController = PagingController(
    firstPageKey: '',
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

  @override
  void initState() {
    super.initState();
    final wallState = context.read<WallsBloc>().state;
    _pagingController.addPageRequestListener(
      (pageKey) {
        // sessionId will be null for sortMode: latest(new)
        String? sessionId;
        // pageKey will be empty string '' for first load and refreshes
        // in those cases, sessionId should be null to create new session
        // else, copy sessionId from the previous response
        if (pageKey != '') {
          sessionId =
              context.read<ListItemsBloc>().state.itemList.metadata.sessionId;
        }
        context.read<ListItemsBloc>().add(
              ListItemsRequested(
                parentId: wallState.currentWall!.id,
                parentType: ListItemsParentType.wall,
                after: pageKey,
                sortMode: wallState.wallSort.code,
                pageSize: ServerConstants.defaultPaginationPageSize,
                sessionId: sessionId,
              ),
            );
      },
    );

    // Set initial shimmer loader type
    _setShimmerLoaderType(wallState.wallView);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListItemsBloc, ListItemsState>(
      listener: (context, state) {
        if (state.status != ListItemsStatus.loading) {
          _refreshController.refreshCompleted();
        }
        if (state.status == ListItemsStatus.success) {
          if (state.itemList.metadata.nextCursor == '' &&
              state.itemList.metadata.hasMore == false) {
            _pagingController.appendLastPage(state.itemList.items);
          } else {
            _pagingController.appendPage(
              state.itemList.items,
              state.itemList.metadata.nextCursor,
            );
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
            AppPagedList<String, Item>(
              pagingController: _pagingController,
              listType: PagedListType.sliverList,
              itemBuilder: (context, item, index) {
                final wallView = context.read<WallsBloc>().state.wallView;
                switch (wallView) {
                  case WallViewOption.card:
                    return ItemListTileCard(
                      item: item,
                      pagingController: _pagingController,
                    );
                  case WallViewOption.magazine:
                    return ItemListTileMag(
                      item: item,
                      pagingController: _pagingController,
                      isTextOnly: wallView == WallViewOption.text,
                    );
                  case WallViewOption.text:
                    return ItemListTileText(
                      item: item,
                      pagingController: _pagingController,
                    );
                  default:
                    return ItemListTileMag(
                      item: item,
                      pagingController: _pagingController,
                    );
                }
              },
              shimmerLoaderType: _shimmerLoaderType,
              firstPageErrorTitle: TextConstants.itemListFetchErrorTitle,
              newPageErrorTitle: TextConstants.itemListFetchErrorTitle,
              noMoreItemsErrorTitle:
                  TextConstants.itemListNoMoreItemsErrorTitle,
              noMoreItemsErrorMessage:
                  TextConstants.itemListNoMoreItemsErrorMessage,
              listEmptyErrorTitle: TextConstants.itemListEmptyMessageTitle,
              listEmptyErrorMessage:
                  TextConstants.itemListEmptyFollowMessageMessage,
            ),
          ],
        ),
      ),
    );
  }
}
