import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/utils/throttle_droppable.dart';
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
        super(const FeedState()) {
    on<FeedSearchRequested>(
      _onFeedListFeeds,
      transformer: throttleDroppable(ServerConstants.throttleDuration),
    );
  }

  void _onFeedListFeeds(
    FeedSearchRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.hasReachedMax) return;
    if (state.status == FeedStatus.initial) {
      final res = await _listFeeds(
        ListFeedParams(
          searchKey: event.searchKey,
          searchValue: event.searchValue,
          sortKey: event.sortKey,
          page: event.page,
          pageSize: event.pageSize,
        ),
      );

      switch (res) {
        case Left(value: _):
          emit(state.copyWith(status: FeedStatus.failure));
        case Right(value: final r):
          emit(state.copyWith(
            status: FeedStatus.success,
            feedList: r,
            hasReachedMax: false,
          ));
      }
      return;
    }
    final res = await _listFeeds(
      ListFeedParams(
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        sortKey: event.sortKey,
        page: state.feedList.metadata.currentPage + 1,
        pageSize: event.pageSize,
      ),
    );

    switch (res) {
      case Left(value: _):
        emit(state.copyWith(status: FeedStatus.failure));
      case Right(value: final r):
        if (r.feeds.isEmpty) {
          emit(state.copyWith(hasReachedMax: true));
        } else {
          emit(state.copyWith(
            status: FeedStatus.success,
            feedList: FeedList(
              feeds: state.feedList.feeds..addAll(r.feeds),
              metadata: r.metadata,
            ),
          ));
        }
    }
  }
}
