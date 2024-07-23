import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/debouncer.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../widgets/search_paged_list.dart';

class SearchFeedsPage extends StatefulWidget {
  const SearchFeedsPage({super.key});

  @override
  State<SearchFeedsPage> createState() => _SearchFeedsPageState();
}

class _SearchFeedsPageState extends State<SearchFeedsPage> {
  final PagingController<int, Feed> _pagingController = PagingController(
    firstPageKey: 1,
    // invisibleItemsThreshold will determine how many items should be loaded
    // after the first page is loaded (if the first page does not fill the
    // screen, items enough to fill the page will be loaded anyway unless
    // invisibleItemsThreshold is set to 0).
    invisibleItemsThreshold: 1,
  );
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  final Debouncer _debouncer = Debouncer(
    duration: ServerConstants.debounceDuration,
  );

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        var nextPageSize = ServerConstants.defaultPaginationPageSize;
        if (pageKey != _pagingController.firstPageKey) {
          nextPageSize = ServerConstants.defaultPaginationNextPageSize;
        }
        context.read<FeedBloc>().add(
              FeedSearchRequested(
                searchKey: 'title',
                searchValue: _searchQuery,
                page: pageKey,
                pageSize: nextPageSize,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.pagePadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: context.theme.textTheme.bodyMedium,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: BlocListener<FeedBloc, FeedState>(
              listener: (context, state) {
                if (state.status != FeedStatus.loading) {
                  _refreshController.refreshCompleted();
                }
                if (state.status == FeedStatus.success) {
                  if (state.feedList.metadata.currentPage ==
                      state.feedList.metadata.lastPage) {
                    _pagingController.appendLastPage(state.feedList.feeds);
                  } else {
                    final nextPage = state.feedList.metadata.currentPage + 1;
                    _pagingController.appendPage(
                        state.feedList.feeds, nextPage);
                  }
                } else if (state.status == FeedStatus.failure) {
                  _pagingController.error = state.message;
                }
              },
              child: SearchPagedList(
                pagingController: _pagingController,
                refreshController: _refreshController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
