import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchFeedsPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const SearchFeedsPage());

  const SearchFeedsPage({super.key});

  @override
  State<SearchFeedsPage> createState() => _SearchFeedsPageState();
}

class _SearchFeedsPageState extends State<SearchFeedsPage> {
  final _scrollController = ScrollController();

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<FeedBloc>().add(FeedSearchRequested(pageSize: 6));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find feeds to follow')),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          switch (state.status) {
            case FeedStatus.failure:
              return const Center(
                child: Text(TextConstants.feedListFetchErrorMessage),
              );
            case FeedStatus.success:
              if (state.feedList.feeds.isEmpty) {
                return const Center(
                  child: Text(TextConstants.feedListEmptyMessage),
                );
              }
              return ListView.builder(
                itemCount: state.hasReachedMax
                    ? state.feedList.feeds.length
                    : state.feedList.feeds.length + 1,
                itemBuilder: (context, index) {
                  return index >= state.feedList.feeds.length
                      ? const SizedBox(height: 100, child: Loader())
                      : ListTile(
                          title: Text(state.feedList.feeds[index].title),
                          subtitle: Text(
                              state.feedList.feeds[index].description ?? ''),
                        );
                },
                controller: _scrollController,
              );
            case FeedStatus.initial:
              return const Loader();
          }
        },
      ),
    );
  }
}
