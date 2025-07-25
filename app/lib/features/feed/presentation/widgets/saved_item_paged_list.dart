import 'package:app/core/common/cubits/network/network_cubit.dart';
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
        BlocListener<SavedItemsBloc, SavedItemsState>(
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
                  (state.action == SavedItemsAction.unsave && state.refresh)) {
                _pagingController.refresh();
              }
            } else if (state.status == SavedItemsStatus.failure) {
              _pagingController.error =
                  state.message ?? TextConstants.internalServerErrorMessage;
            }
          },
          child: Expanded(
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
                    color: context.theme.colorScheme.onSurface.withAlpha(102),
                    strokeWidth: 2,
                  ),
                ),
              ),
              child: CustomScrollView(
                cacheExtent: 500,
                slivers: [
                  AppPagedList(
                    pagingController: _pagingController,
                    listType: PagedListType.sliverList,
                    itemBuilder: (context, savedItem, index) {
                      return Dismissible(
                        key: Key(savedItem.item.id.toString()),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            context
                                .read<SavedItemsBloc>()
                                .add(UnsaveItemRequested(
                                  itemId: savedItem.item.id,
                                  refresh: false,
                                ));
                          }
                        },
                        direction: DismissDirection.endToStart,
                        dismissThresholds: const {
                          DismissDirection.endToStart: 0.55,
                        },
                        confirmDismiss: (direction) async {
                          if (context.read<NetworkCubit>().state.status ==
                              NetworkStatus.disconnected) {
                            showSnackbar(
                              context,
                              'No internet connection',
                              type: SnackbarType.failure,
                            );
                            return false;
                          }
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: const EdgeInsets.only(
                                top: 36.0,
                                left: 32.0,
                                right: 24.0,
                                bottom: 24.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              content: Text.rich(
                                TextSpan(
                                  style: context.theme.textTheme.bodyLarge,
                                  children: [
                                    const TextSpan(
                                        text:
                                            'Are you sure you want to remove this from saved items?'),
                                    TextSpan(
                                      text:
                                          '\n\n(This action cannot be undone.)',
                                      style: context.theme.textTheme.bodySmall!
                                          .copyWith(
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: context.theme.textTheme.titleMedium!
                                        .copyWith(
                                      color:
                                          context.theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Yes',
                                    style: context.theme.textTheme.titleMedium!
                                        .copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: context.theme.colorScheme.error.withAlpha(127),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              'Unsave',
                              style:
                                  context.theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        child: SavedItemListTileMag(
                          savedItem: savedItem,
                        ),
                      );
                    },
                    shimmerLoaderType: ShimmerLoaderType.smallmag,
                    shimmerHorizontalPadding: 0,
                    firstPageErrorTitle: TextConstants.itemListFetchErrorTitle,
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
          ),
        ),
      ],
    );
  }
}
