import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/core/utils/stream_tranformers.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'search_feed_event.dart';
part 'search_feed_state.dart';

class SearchFeedBloc extends Bloc<SearchFeedEvent, SearchFeedState> {
  final ListFeeds _listFeeds;

  SearchFeedBloc({
    required ListFeeds listFeeds,
  })  : _listFeeds = listFeeds,
        super(const SearchFeedState()) {
    on<FeedSearchRequested>(
      _onFeedListFeeds,
      transformer: throttleDroppable(ServerConstants.throttleDuration),
    );
  }

  void _onFeedListFeeds(
    FeedSearchRequested event,
    Emitter<SearchFeedState> emit,
  ) async {
    emit(state.copyWith(status: SearchFeedStatus.loading));
    final res = await _listFeeds(
      PaginationParams(
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        sortKey: event.sortKey,
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: SearchFeedStatus.failure,
          message: l.message,
        ));
      case Right(value: final r):
        emit(state.copyWith(
          status: SearchFeedStatus.success,
          feedList: r,
        ));
    }
  }
}
