import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/saved_item.dart';
import 'package:app/features/feed/presentation/bloc/saved_items/saved_items_bloc.dart';
import 'package:app/features/feed/presentation/widgets/saved_item_list_tile_mag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SavedItemPagedList extends StatefulWidget {
  const SavedItemPagedList({super.key});

  @override
  State<SavedItemPagedList> createState() => _SavedItemPagedListState();
}

class _SavedItemPagedListState extends State<SavedItemPagedList> {
  final PagingController<int, SavedItem> _pagingController = PagingController(
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
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(
    duration: ServerConstants.debounceDuration,
  );
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        context.read<SavedItemsBloc>().add(
              ListSavedItemsRequested(
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
                title: _searchQuery,
              ),
            );
      },
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _refreshController.dispose();
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(
      () {
        if (_searchQuery != _searchController.text) {
          setState(() {
            _searchQuery = _searchController.text;
          });
          _pagingController.refresh();
        }
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged();
  }

  _searchBorder() => OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(
          UIConstants.searchInputBorderRadius,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 12.0,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              border: _searchBorder(),
              focusedBorder: _searchBorder(),
              enabledBorder: _searchBorder(),
              filled: true,
              fillColor: context.theme.colorScheme.surfaceContainer,
              hintText: 'Search...',
              hintStyle: context.theme.textTheme.bodyMedium,
              prefixIcon: const Icon(MingCute.search_line),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        BlocConsumer<SavedItemsBloc, SavedItemsState>(
          listener: (context, state) {
            if (state.status != SavedItemsStatus.loading) {
              _refreshController.refreshCompleted();
            }
            if (state.status == SavedItemsStatus.success) {
              if (state.action == SavedItemsAction.list) {
                if (state.savedItemList.metadata.currentPage ==
                    state.savedItemList.metadata.lastPage) {
                  _pagingController
                      .appendLastPage(state.savedItemList.savedItems);
                } else {
                  final nextPage = state.savedItemList.metadata.currentPage + 1;
                  _pagingController.appendPage(
                      state.savedItemList.savedItems, nextPage);
                }
              } else if (state.action == SavedItemsAction.save ||
                  state.action == SavedItemsAction.unsave) {
                _pagingController.refresh();
              }
            } else if (state.status == SavedItemsStatus.failure) {
              _pagingController.error =
                  state.message ?? TextConstants.internalServerErrorMessage;
            }
          },
          buildWhen: (previous, current) =>
              previous.status != current.status &&
              previous.action != current.action,
          builder: (context, state) {
            if (state.status == SavedItemsStatus.loading) {
              return const Expanded(
                child: ShimmerLoader(
                  pageSize: 5,
                  type: ShimmerLoaderType.smallmag,
                ),
              );
            }
            return Expanded(
              child: Refresher(
                controller: _refreshController,
                onRefresh: () async {
                  _pagingController.refresh();
                },
                header: ClassicHeader(
                  refreshingIcon: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color:
                          context.theme.colorScheme.onSurface.withOpacity(0.4),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                child: CustomScrollView(
                  cacheExtent: 500,
                  slivers: [
                    AppPagedList<SavedItem>(
                      pagingController: _pagingController,
                      listType: PagedListType.sliverList,
                      itemBuilder: (context, savedItem, index) {
                        return SavedItemListTileMag(
                          savedItem: savedItem,
                        );
                      },
                      shimmerLoaderType: ShimmerLoaderType.smallmag,
                      firstPageErrorTitle:
                          TextConstants.itemListFetchErrorTitle,
                      newPageErrorTitle: TextConstants.itemListFetchErrorTitle,
                      noMoreItemsErrorTitle: '',
                      noMoreItemsErrorMessage: '',
                      listEmptyErrorTitle:
                          TextConstants.itemListEmptyMessageTitle,
                      listEmptyErrorMessage:
                          'You haven\'t saved any articles yet',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
