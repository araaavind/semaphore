import 'package:app/core/constants/server_constants.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/usecases/check_user_follows_feeds.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'search_feed_event.dart';
part 'search_feed_state.dart';

class SearchFeedBloc extends Bloc<SearchFeedEvent, SearchFeedState> {
  final ListFeeds _listFeeds;
  final CheckUserFollowsFeeds _checkUserFollowsFeeds;

  SearchFeedBloc({
    required ListFeeds listFeeds,
    required CheckUserFollowsFeeds checkUserFollowsFeeds,
  })  : _listFeeds = listFeeds,
        _checkUserFollowsFeeds = checkUserFollowsFeeds,
        super(const SearchFeedState()) {
    on<FeedSearchRequested>(
      _onFeedListFeeds,
      // transformer: throttleDroppable(ServerConstants.throttleDuration),
    );
  }

  void _onFeedListFeeds(
    FeedSearchRequested event,
    Emitter<SearchFeedState> emit,
  ) async {
    emit(state.copyWith(status: SearchFeedStatus.loading));
    final feedsRes = await _listFeeds(
      ListFeedsParams(
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        topicId: event.topicId,
        feedType: event.feedType,
        sortKey: event.sortKey,
        page: event.page,
        pageSize: event.pageSize,
        type: event.type,
      ),
    );

    switch (feedsRes) {
      case Left(value: final l):
        emit(state.copyWith(
          status: SearchFeedStatus.failure,
          message: l.message,
        ));
      case Right(value: final feedList):
        if (event.type == ListFeedsType.followed) {
          emit(state.copyWith(
            status: SearchFeedStatus.success,
            feedList: feedList,
          ));
          return;
        }
        final feedIds = feedList.feeds.map((feed) => feed.id).toList();
        final followsRes = await _checkUserFollowsFeeds(feedIds);
        switch (followsRes) {
          case Left(value: final l):
            emit(state.copyWith(
              status: SearchFeedStatus.failure,
              message: l.message,
            ));
          case Right(value: final followsList):
            emit(state.copyWith(
              status: SearchFeedStatus.success,
              feedList: feedList,
              followsList: followsList,
            ));
        }
    }
  }
}
