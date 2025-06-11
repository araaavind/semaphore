import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/services/analytics_service.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/feed/domain/usecases/add_feed_to_wall.dart';
import 'package:app/features/feed/domain/usecases/remove_feed_from_wall.dart';
import 'package:fpdart/fpdart.dart';

part 'wall_feed_event.dart';
part 'wall_feed_state.dart';

class WallFeedBloc extends Bloc<WallFeedEvent, WallFeedState> {
  final AddFeedToWall _addFeedToWall;
  final RemoveFeedFromWall _removeFeedFromWall;
  final ListFeeds _listFeeds;

  WallFeedBloc({
    required AddFeedToWall addFeedToWall,
    required RemoveFeedFromWall removeFeedFromWall,
    required ListFeeds listFeeds,
  })  : _addFeedToWall = addFeedToWall,
        _removeFeedFromWall = removeFeedFromWall,
        _listFeeds = listFeeds,
        super(WallFeedInitial()) {
    on<AddFeedToWallRequested>(_onAddFeedToWallRequested);
    on<RemoveFeedFromWallRequested>(_onRemoveFeedFromWallRequested);
    on<ListWallFeedsRequested>(_onListWallFeedsRequested);
  }

  Future<void> _onAddFeedToWallRequested(
    AddFeedToWallRequested event,
    Emitter<WallFeedState> emit,
  ) async {
    emit(
      WallFeedLoading(
        wallId: event.wallId,
        feedId: event.feedId,
        action: WallFeedAction.add,
      ),
    );
    final result = await _addFeedToWall(AddFeedToWallParams(
      feedId: event.feedId,
      wallId: event.wallId,
    ));
    switch (result) {
      case Left(value: final l):
        emit(WallFeedFailure(
          message: l.message,
          wallId: event.wallId,
          feedId: event.feedId,
          action: WallFeedAction.add,
        ));
      case Right(value: _):
        AnalyticsService.logFeedAddedToWall(
            '${event.wallId}', '${event.feedId}');
        emit(WallFeedSuccess(
          wallId: event.wallId,
          feedId: event.feedId,
          action: WallFeedAction.add,
        ));
    }
  }

  Future<void> _onRemoveFeedFromWallRequested(
    RemoveFeedFromWallRequested event,
    Emitter<WallFeedState> emit,
  ) async {
    emit(WallFeedLoading(
      wallId: event.wallId,
      feedId: event.feedId,
      action: WallFeedAction.remove,
    ));
    final result = await _removeFeedFromWall(RemoveFeedFromWallParams(
      feedId: event.feedId,
      wallId: event.wallId,
    ));
    switch (result) {
      case Left(value: final l):
        emit(WallFeedFailure(
          message: l.message,
          wallId: event.wallId,
          feedId: event.feedId,
          action: WallFeedAction.remove,
        ));
      case Right(value: _):
        emit(WallFeedSuccess(
          wallId: event.wallId,
          feedId: event.feedId,
          action: WallFeedAction.remove,
        ));
    }
  }

  Future<void> _onListWallFeedsRequested(
    ListWallFeedsRequested event,
    Emitter<WallFeedState> emit,
  ) async {
    emit(WallFeedLoading(wallId: event.wallId, action: WallFeedAction.list));
    final result = await _listFeeds(
      ListFeedsParams(
        wallId: event.wallId,
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        sortKey: event.sortKey,
        page: event.page,
        pageSize: event.pageSize,
        type: ListFeedsType.wall,
      ),
    );
    switch (result) {
      case Left(value: final l):
        emit(
          WallFeedFailure(
            message: l.message,
            wallId: event.wallId,
            action: WallFeedAction.list,
          ),
        );
      case Right(value: final r):
        emit(
          WallFeedSuccess(
            wallId: event.wallId,
            action: WallFeedAction.list,
            feedList: r,
          ),
        );
    }
  }
}
