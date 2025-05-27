import 'dart:ui';

import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/pages/explore_page.dart';
import 'package:app/features/feed/presentation/widgets/feed_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  final Debouncer _debouncer = Debouncer(
    duration: ServerConstants.debounceDuration,
  );

  String _searchQuery = '';
  Topic? _selectedTopic;
  Color? _selectedTopicColor;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        context.read<SearchFeedBloc>().add(
              FeedSearchRequested(
                searchKey: 'title',
                searchValue: _searchQuery,
                topicId: _selectedTopic?.id,
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

  _topicPageSearchBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color.withAlpha(20),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(
          UIConstants.searchInputBorderRadius,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_selectedTopic != null) {
          setState(() {
            _selectedTopic = null;
            _selectedTopicColor = null;
          });
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: _selectedTopic != null
            ? _buildTopicPageAppBar(context)
            : _buildSearchPageAppBar(context),
        backgroundColor: _selectedTopicColor?.withAlpha(10),
        body: Column(
          children: [
            _searchQuery.isEmpty && _selectedTopic == null
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: UIConstants.pagePadding,
                      ),
                      child: TopicsGrid(
                        onTap: (topic, color) {
                          setState(() {
                            _selectedTopic = topic;
                            _selectedTopicColor = color;
                          });
                        },
                      ),
                    ),
                  )
                : Expanded(
                    child: BlocListener<SearchFeedBloc, SearchFeedState>(
                      listener: (context, state) {
                        if (state.status == SearchFeedStatus.success) {
                          var feedFollowsList = <FeedFollowsMap>[];
                          for (var i = 0;
                              i < state.feedList.feeds.length;
                              i++) {
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
                            final nextPage =
                                state.feedList.metadata.currentPage + 1;
                            _pagingController.appendPage(
                                feedFollowsList, nextPage);
                          }
                        } else if (state.status == SearchFeedStatus.failure) {
                          _pagingController.error = state.message;
                        }
                      },
                      child: AppPagedList(
                        pagingController: _pagingController,
                        listType: PagedListType.list,
                        itemBuilder: (context, item, index) => FeedListTile(
                          feedIsFollowedMap: item,
                          pagingController: _pagingController,
                          index: index,
                        ),
                        shimmerLoaderType: ShimmerLoaderType.feedmag,
                        firstPageErrorTitle:
                            TextConstants.feedListFetchErrorTitle,
                        newPageErrorTitle:
                            TextConstants.feedListFetchErrorTitle,
                        noMoreItemsErrorTitle:
                            TextConstants.feedListEmptyMessageTitle,
                        noMoreItemsErrorMessage:
                            TextConstants.feedListEmptyMessageMessage,
                        listEmptyErrorTitle:
                            TextConstants.feedListEmptyMessageTitle,
                        listEmptyErrorMessage:
                            TextConstants.feedListEmptyMessageMessage,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopicPageAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight * 2 + 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _selectedTopicColor!.withAlpha(50),
              _selectedTopicColor!.withAlpha(25),
              _selectedTopicColor!.withAlpha(0),
            ],
            stops: const [0.0, 0.3, 0.8],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          top: 8.0,
          bottom: 6.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight - 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTopic = null;
                      _selectedTopicColor = null;
                    });
                  },
                  child: const Icon(Icons.close_outlined),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _selectedTopic!.name,
                      style: context.theme.textTheme.titleMedium!.copyWith(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.wavy,
                        decorationThickness: 4,
                        decorationColor: _selectedTopicColor,
                        color: Colors.transparent,
                        shadows: [
                          Shadow(
                            color: context.theme.textTheme.titleMedium!.color ??
                                Colors.black,
                            offset:
                                const Offset(0, -8), // Negative y moves text up
                          ),
                        ],
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            TextField(
              controller: _searchController,
              cursorColor: _selectedTopicColor,
              decoration: InputDecoration(
                border: _topicPageSearchBorder(_selectedTopicColor!),
                focusedBorder: _topicPageSearchBorder(_selectedTopicColor!),
                enabledBorder: _topicPageSearchBorder(_selectedTopicColor!),
                filled: true,
                fillColor: HSLColor.fromColor(_selectedTopicColor!)
                    .withLightness(
                        context.theme.brightness == Brightness.dark ? 0.2 : 0.7)
                    .withSaturation(0.2)
                    .toColor()
                    .withAlpha(95),
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
          ],
        ),
      ),
    );
  }

  AppBar _buildSearchPageAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Explore',
        style: context.theme.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      toolbarHeight: kToolbarHeight * 1.2,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.theme.colorScheme.surfaceContainer,
              context.theme.brightness == Brightness.dark
                  ? context.theme.colorScheme.surface.withAlpha(0)
                  : context.theme.colorScheme.surface.withAlpha(0),
            ],
          ),
        ),
      ),
      bottom: AppBar(
        toolbarHeight: kToolbarHeight * 1.2,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              border: _searchBorder(),
              focusedBorder: _searchBorder(),
              enabledBorder: _searchBorder(),
              filled: true,
              fillColor:
                  context.theme.colorScheme.surfaceContainerHigh.withAlpha(217),
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
      ),
      actions: [
        Padding(
          padding: UIConstants.defaultAppBarTextButtonPadding,
          child: TextButton(
            onPressed: () async {
              final result = await context.pushNamed('add-feed');
              if (result is Map<String, dynamic> && result['success'] == true) {
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
                        pathParameters: {'feedId': result['feedId'].toString()},
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Icon(
                    MingCute.add_fill,
                    size: 18.0,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4.0),
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
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: context.theme.colorScheme.surfaceContainer.withAlpha(0),
        statusBarIconBrightness: context.theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
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
