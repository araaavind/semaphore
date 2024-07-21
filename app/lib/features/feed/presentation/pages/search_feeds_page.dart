import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchFeedsPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const SearchFeedsPage());

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
                page: pageKey,
                pageSize: nextPageSize,
              ),
            );
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state.status == FeedStatus.success) {
            if (state.feedList.metadata.currentPage ==
                state.feedList.metadata.lastPage) {
              _pagingController.appendLastPage(state.feedList.feeds);
            } else {
              final nextPage = state.feedList.metadata.currentPage + 1;
              _pagingController.appendPage(state.feedList.feeds, nextPage);
            }
          } else if (state.status == FeedStatus.failure) {
            _pagingController.error = state.message;
          }
        },
        child: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
          child: PagedListView<int, Feed>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Feed>(
              itemBuilder: (context, item, index) => ListTile(
                title: Text(
                  item.title,
                  style: context.theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  item.description ?? '',
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                title: TextConstants.feedListFetchErrorTitle,
                message: _pagingController.error,
                onTryAgain: () {
                  _pagingController.refresh();
                },
              ),
              newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                title: TextConstants.feedListFetchErrorTitle,
                message: _pagingController.error,
                onTap: _pagingController.retryLastFailedRequest,
              ),
              newPageProgressIndicatorBuilder: (_) =>
                  const ShimmerLoader(pageSize: 1),
              firstPageProgressIndicatorBuilder: (_) => const ShimmerLoader(
                  pageSize: ServerConstants.defaultPaginationPageSize),
              noMoreItemsIndicatorBuilder: (_) => const NoMoreItemsIndicator(),
              noItemsFoundIndicatorBuilder: (_) => const NoMoreItemsIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
