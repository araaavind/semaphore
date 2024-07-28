import 'package:app/features/feed/domain/usecases/follow_feed.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'follow_feed_event.dart';
part 'follow_feed_state.dart';

class FollowFeedBloc extends Bloc<FollowFeedEvent, FollowFeedState> {
  final FollowFeed _followFeed;

  FollowFeedBloc({
    required FollowFeed followFeed,
  })  : _followFeed = followFeed,
        super(const FollowFeedState(status: FollowFeedStatus.initial)) {
    on<FollowFeedRequested>(_onFollowFeedRequested);
  }

  void _onFollowFeedRequested(
    FollowFeedRequested event,
    Emitter<FollowFeedState> emit,
  ) async {
    emit(state.copyWith(
      status: FollowFeedStatus.loading,
      feedId: event.feedId,
    ));

    final res = await _followFeed(FollowFeedParams(event.feedId));
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: FollowFeedStatus.failure,
          feedId: event.feedId,
          message: l.message,
        ));
      case Right():
        emit(state.copyWith(
          status: FollowFeedStatus.success,
          feedId: event.feedId,
        ));
    }
  }
}
