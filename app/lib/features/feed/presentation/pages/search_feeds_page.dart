import 'dart:math';

import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed_follows_map.dart';
import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/widgets/feed_list_tile.dart';
import 'package:app/features/feed/presentation/widgets/topics_grid.dart';
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
  Topic? _selectedSubtopic;
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
                topicId: _selectedSubtopic?.id ?? _selectedTopic?.id,
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
              ),
            );
      },
    );
    _searchController.addListener(_onSearchChanged);

    // Show onboarding popup if this is onboarding flow
    if (widget.isOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboardingGuide();
      });
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectTopic(Topic topic, Color color) {
    setState(() {
      _selectedTopic = topic;
      _selectedTopicColor = color;
      _selectedSubtopic = null;
    });
    _pagingController.refresh();
  }

  void _clearTopic() {
    setState(() {
      _selectedTopic = null;
      _selectedTopicColor = null;
      _selectedSubtopic = null;
    });
    _pagingController.refresh();
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

  void _onSubtopicSelectionChanged(Topic subtopic, bool selected) {
    _debouncer.run(() {
      setState(() {
        if (selected) {
          _selectedSubtopic = subtopic;
        } else {
          _selectedSubtopic = null;
        }
      });
      _pagingController.refresh();
    });
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

  void _showOnboardingGuide() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.theme.colorScheme.primaryContainer.withAlpha(180),
                  context.theme.colorScheme.surfaceContainer,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: context.theme.colorScheme.primary,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 18.0),
                    Expanded(
                      child: Text(
                        'Welcome to Semaphore!',
                        style: context.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: HSLColor.fromColor(
                                  context.theme.colorScheme.primary)
                              .withLightness(
                                context.theme.brightness == Brightness.dark
                                    ? 0.9
                                    : 0.1,
                              )
                              .toColor(),
                        ),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () => Navigator.of(context).pop(),
                    //   icon: const Icon(Icons.close),
                    //   iconSize: 20.0,
                    // ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Get started by following feeds that interest you',
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Browse through different topics or search for specific feeds. If you can\'t find what you\'re looking for, there is an option on top to add them yourself!',
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Got it!',
                        style: TextStyle(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        if (GoRouterState.of(context).topRoute?.name !=
            RouteConstants.searchFeedsPageName) {
          return false;
        }
        if (_selectedTopic != null) {
          _clearTopic();
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
            if (_selectedTopic != null &&
                _selectedTopic!.subTopics != null &&
                _selectedTopic!.subTopics!.isNotEmpty)
              _buildSubtopicSelector(),
            _searchQuery.isEmpty && _selectedTopic == null
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: UIConstants.pagePadding,
                      ),
                      child: TopicsGrid(
                        onTap: _selectTopic,
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
                          altPrimaryColor: _selectedTopicColor,
                        ),
                        loaderType:
                            PagedListLoaderType.circularProgressIndicator,
                        // shimmerLoaderType: ShimmerLoaderType.feedmag,
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
                  onTap: _clearTopic,
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
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
              AppPalette.appBarGradientColor
                  .withLightness(
                    context.theme.brightness == Brightness.dark ? 0.75 : 0.3,
                  )
                  .toColor(),
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

  Widget _buildSubtopicSelector() {
    _selectedTopic!.subTopics!
        .sort((a, b) => a.name.length.compareTo(b.name.length));

    double totalChipWidth = 0;
    List<double> chipWidths = [];

    // Create a TextPainter to measure text dimensions
    final textStyle = context.theme.textTheme.bodySmall?.copyWith(
      color: context.theme.colorScheme.onSurface.withAlpha(235),
    );

    // Add width for each subtopic chip
    for (final subTopic in _selectedTopic!.subTopics!) {
      // Create a TextPainter to measure this specific text
      final textPainter = TextPainter(
        text: TextSpan(text: subTopic.name, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      // Add text width + chip padding + border
      // 18 accounts for padding 16 + 2 border on both sides
      // 8 accounts for spacing between chips
      double chipWidth = textPainter.width + 18 + 8;
      chipWidths.add(chipWidth);
      totalChipWidth += chipWidth;
    }

    // Calculate how much the content might exceed the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double maxRowWidth = 0;
    if (totalChipWidth > 2 * screenWidth) {
      for (final chipWidth in chipWidths) {
        maxRowWidth += chipWidth;
        if (maxRowWidth > totalChipWidth / 2) {
          break;
        }
      }
    } else {
      maxRowWidth = totalChipWidth;
    }

    // Calculate how much the content should exceed the screen width
    maxRowWidth += 16; // accounting for checkmark
    maxRowWidth += 16; // safe offset

    double multiplier = max(
      1.0,
      maxRowWidth / (screenWidth - 16), // 16 for container padding
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: screenWidth * multiplier,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8.0,
          runSpacing: 0.0,
          children: _selectedTopic!.subTopics!.map(
            (subTopic) {
              return ChoiceChip(
                visualDensity: VisualDensity.compact,
                showCheckmark: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                side: BorderSide(
                  color: _selectedTopicColor!.withAlpha(50),
                ),
                label: Text(
                  subTopic.name,
                  style: textStyle,
                ),
                color: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _selectedTopicColor!.withAlpha(50);
                  }
                  return Colors.transparent;
                }),
                selected: _selectedSubtopic?.id == subTopic.id,
                onSelected: (selected) {
                  _onSubtopicSelectionChanged(subTopic, selected);
                },
              );
            },
          ).toList(),
        ),
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
