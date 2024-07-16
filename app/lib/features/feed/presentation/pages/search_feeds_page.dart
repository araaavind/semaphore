import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/utils/show_snackbar.dart';
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
  @override
  void initState() {
    context.read<FeedBloc>().add(FeedListFeedsEvent(
        pageSize: 12, searchKey: 'title', searchValue: '', sortKey: 'title'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find feeds to follow')),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state is FeedFailed) {
            showSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Loader();
          }
          if (state is FeedInitial) {
            return const Center(
              child: Text(ServerConstants.internalServerErrorMessage),
            );
          }
          return ListView.builder(
            itemCount: (state as FeedListFetched).feedList.feeds.length,
            itemBuilder: (context, index) {
              final feed = state.feedList.feeds[index];
              return ListTile(
                title: Text(feed.title),
                subtitle: Text(feed.description ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
