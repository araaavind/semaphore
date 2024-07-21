import 'package:app/core/common/widgets/first_page_error_indicator.dart';
import 'package:app/core/common/widgets/new_page_error_indicator.dart';
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
  final PagingController<int, Feed> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) => context.read<FeedBloc>().add(
            FeedSearchRequested(page: pageKey),
          ),
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
                title: Text(item.title),
                subtitle: Text(item.description ?? ''),
              ),
              firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                title: 'Failed to load feeds',
                message: _pagingController.error,
                onTryAgain: () {
                  _pagingController.refresh();
                },
              ),
              newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                title: 'Failed to load feeds',
                message: _pagingController.error,
                onTap: _pagingController.retryLastFailedRequest,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
