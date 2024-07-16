import 'package:app/core/constants/server_constants.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final ListFeeds _listFeeds;

  FeedBloc({
    required ListFeeds listFeeds,
  })  : _listFeeds = listFeeds,
        super(FeedInitial()) {
    on<FeedListFeedsEvent>(_onFeedListFeeds);
  }

  void _onFeedListFeeds(
      FeedListFeedsEvent event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    final res = await _listFeeds(
      ListFeedParams(
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        page: event.page,
        pageSize: event.pageSize,
        sortKey: event.sortKey,
      ),
    );

    switch (res) {
      case Left(value: final l):
        emit(FeedFailed(l.message));
      case Right(value: final r):
        emit(FeedListFetched(r));
    }
  }
}
