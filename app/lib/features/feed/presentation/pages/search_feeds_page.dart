import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/feed/presentation/widgets/feed_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchFeedsPage extends StatefulWidget {
  final bool isOnboarding;

  const SearchFeedsPage({super.key, this.isOnboarding = false});

  @override
  State<SearchFeedsPage> createState() => _SearchFeedsPageState();
}

class _SearchFeedsPageState extends State<SearchFeedsPage> {
  final PagingController<int, FeedFollowsMap> _pagingController =
      PagingController(
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
        context.read<SearchFeedBloc>().add(
              FeedSearchRequested(
                searchKey: 'title',
                searchValue: _searchQuery,
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Semaphore',
          style: context.theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w900,
            color: context.theme.brightness == Brightness.dark
                ? AppPalette.brandDark
                : AppPalette.brand,
          ),
        ),
        actions: [
          Padding(
            padding: UIConstants.defaultAppBarTextButtonPadding,
            child: TextButton(
              onPressed: () async {
                final result = await context.pushNamed('add-feed');
                if (result is Map<String, dynamic> &&
                    result['success'] == true) {
                  _pagingController.refresh();
                  if (context.mounted) {
                    showSnackbar(
                      context,
                      'Followed feed',
                      type: SnackbarType.utility,
                      actionLabel: 'Add to walls',
                      onActionPressed: () {
                        context.pushNamed(
                          RouteConstants.addToWallPageName,
                          pathParameters: {
                            'feedId': result['feedId'].toString()
                          },
                          extra: {
                            'wallsBloc': BlocProvider.of<WallsBloc>(context),
                          },
                        );
                      },
                    );
                  }
                }
              },
              style: const ButtonStyle(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    size: 26.0,
                    color: context.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    'Add feed',
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.isOnboarding) const TitleTextSpan(),
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 6.0,
              bottom: 12.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: _searchBorder(),
                focusedBorder: _searchBorder(),
                enabledBorder: _searchBorder(),
                filled: true,
                fillColor: context.theme.colorScheme.outline.withAlpha(100),
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
            child: BlocListener<SearchFeedBloc, SearchFeedState>(
              listener: (context, state) {
                if (state.status != SearchFeedStatus.loading) {
                  _refreshController.refreshCompleted();
                }
                if (state.status == SearchFeedStatus.success) {
                  var feedFollowsList = <FeedFollowsMap>[];
                  for (var i = 0; i < state.feedList.feeds.length; i++) {
                    feedFollowsList.add(
                      FeedFollowsMap(
                        feed: state.feedList.feeds[i],
                        isFollowed: state.followsList[i],
                      ),
                    );
                  }
                  if (state.feedList.metadata.currentPage ==
                      state.feedList.metadata.lastPage) {
                    _pagingController.appendLastPage(feedFollowsList);
                  } else {
                    final nextPage = state.feedList.metadata.currentPage + 1;
                    _pagingController.appendPage(feedFollowsList, nextPage);
                  }
                } else if (state.status == SearchFeedStatus.failure) {
                  _pagingController.error = state.message;
                }
              },
              child: Refresher(
                controller: _refreshController,
                onRefresh: () async => _pagingController.refresh(),
                child: AppPagedList(
                  pagingController: _pagingController,
                  listType: PagedListType.list,
                  itemBuilder: (context, item, index) => FeedListTile(
                    feedIsFollowedMap: item,
                    pagingController: _pagingController,
                    index: index,
                  ),
                  firstPageErrorTitle: TextConstants.feedListFetchErrorTitle,
                  newPageErrorTitle: TextConstants.feedListFetchErrorTitle,
                  noMoreItemsErrorTitle:
                      TextConstants.feedListEmptyMessageTitle,
                  noMoreItemsErrorMessage:
                      TextConstants.feedListEmptyMessageMessage,
                  listEmptyErrorTitle: TextConstants.feedListEmptyMessageTitle,
                  listEmptyErrorMessage:
                      TextConstants.feedListEmptyMessageMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TitleTextSpan extends StatelessWidget {
  const TitleTextSpan({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow the feeds that interest you',
          style: context.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w100,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
