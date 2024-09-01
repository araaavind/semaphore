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

  WallFeedBloc({
    required AddFeedToWall addFeedToWall,
    required RemoveFeedFromWall removeFeedFromWall,
  })  : _addFeedToWall = addFeedToWall,
        _removeFeedFromWall = removeFeedFromWall,
        super(WallFeedInitial()) {
    on<AddFeedToWallRequested>(_onAddFeedToWallRequested);
    on<RemoveFeedFromWallRequested>(_onRemoveFeedFromWallRequested);
  }

  Future<void> _onAddFeedToWallRequested(
    AddFeedToWallRequested event,
    Emitter<WallFeedState> emit,
  ) async {
    emit(WallFeedLoading(wallId: event.wallId));
    final result = await _addFeedToWall(AddFeedToWallParams(
      feedId: event.feedId,
      wallId: event.wallId,
    ));
    switch (result) {
      case Left(value: final l):
        emit(WallFeedFailure(message: l.message, wallId: event.wallId));
      case Right(value: _):
        emit(WallFeedSuccess(wallId: event.wallId));
    }
  }

  Future<void> _onRemoveFeedFromWallRequested(
    RemoveFeedFromWallRequested event,
    Emitter<WallFeedState> emit,
  ) async {
    emit(WallFeedLoading(wallId: event.wallId));
    final result = await _removeFeedFromWall(RemoveFeedFromWallParams(
      feedId: event.feedId,
      wallId: event.wallId,
    ));
    switch (result) {
      case Left(value: final l):
        emit(WallFeedFailure(message: l.message, wallId: event.wallId));
      case Right(value: _):
        emit(WallFeedSuccess(wallId: event.wallId));
    }
  }
}
