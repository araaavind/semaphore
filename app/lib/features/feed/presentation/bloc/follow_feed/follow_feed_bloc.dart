import 'package:app/core/services/analytics_service.dart';
import 'package:app/features/feed/domain/usecases/add_follow_feed.dart';
import 'package:app/features/feed/domain/usecases/follow_feed.dart';
import 'package:app/features/feed/domain/usecases/unfollow_feed.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'follow_feed_event.dart';
part 'follow_feed_state.dart';

class FollowFeedBloc extends Bloc<FollowFeedEvent, FollowFeedState> {
  final FollowFeed _followFeed;
  final UnfollowFeed _unfollowFeed;

  FollowFeedBloc({
    required FollowFeed followFeed,
    required UnfollowFeed unfollowFeed,
  })  : _followFeed = followFeed,
        _unfollowFeed = unfollowFeed,
        super(const FollowFeedState(status: FollowFeedStatus.unfollowed)) {
    on<FollowUnfollowRequested>(_onFollowFeedRequested);
  }

  void _onFollowFeedRequested(
    FollowUnfollowRequested event,
    Emitter<FollowFeedState> emit,
  ) async {
    if (event.action == FollowUnfollowAction.follow) {
      emit(state.copyWith(
        status: FollowFeedStatus.loading,
        feedId: event.feedId,
      ));
      final res = await _followFeed(event.feedId);
      switch (res) {
        case Left(value: final l):
          emit(state.copyWith(
            status: FollowFeedStatus.failure,
            feedId: event.feedId,
            message: l.message,
          ));
        case Right():
          AnalyticsService.logFeedFollowed('${event.feedId}', 'follow');
          emit(state.copyWith(
            status: FollowFeedStatus.followed,
            feedId: event.feedId,
          ));
      }
    } else {
      emit(state.copyWith(
        status: FollowFeedStatus.loading,
        feedId: event.feedId,
      ));
      final res = await _unfollowFeed(event.feedId);
      switch (res) {
        case Left(value: final l):
          emit(state.copyWith(
            status: FollowFeedStatus.failure,
            feedId: event.feedId,
            message: l.message,
          ));
        case Right():
          AnalyticsService.logFeedRemoved('${event.feedId}');
          emit(state.copyWith(
            status: FollowFeedStatus.unfollowed,
            feedId: event.feedId,
          ));
      }
    }
  }
}

class AddFollowFeedBloc extends Bloc<FollowFeedEvent, AddFollowFeedState> {
  final AddFollowFeed _addFollowFeed;

  AddFollowFeedBloc({
    required AddFollowFeed addFollowFeed,
  })  : _addFollowFeed = addFollowFeed,
        super(const AddFollowFeedState(status: FollowFeedStatus.initial)) {
    on<AddFollowRequested>(_onAddFollowRequested);
  }

  Future<void> _onAddFollowRequested(
    AddFollowRequested event,
    Emitter<AddFollowFeedState> emit,
  ) async {
    emit(state.copyWith(status: FollowFeedStatus.loading));
    final result = await _addFollowFeed(AddFollowFeedParams(
      feedUrl: event.feedUrl,
      feedType: event.feedType,
    ));
    switch (result) {
      case Left(value: final failure):
        emit(state.copyWith(
          status: FollowFeedStatus.failure,
          message: failure.message,
          fieldErrors: failure.fieldErrors,
        ));
      case Right(value: final feedId):
        AnalyticsService.logFeedFollowed(event.feedUrl, 'add_follow');
        emit(state.copyWith(
          status: FollowFeedStatus.followed,
          feedId: feedId,
        ));
    }
  }
}
