part of 'wall_feed_bloc.dart';

enum WallFeedAction { add, remove, list }

abstract class WallFeedState extends Equatable {
  final int? wallId;
  final int? feedId;
  final WallFeedAction? action;
  final FeedList? feedList;

  const WallFeedState({
    this.wallId,
    this.feedId,
    this.action,
    this.feedList,
  });

  @override
  List<Object?> get props => [wallId, feedId, action, feedList];
}

class WallFeedInitial extends WallFeedState {}

class WallFeedLoading extends WallFeedState {
  const WallFeedLoading({
    required int super.wallId,
    required WallFeedAction super.action,
    super.feedId,
  });
}

class WallFeedSuccess extends WallFeedState {
  const WallFeedSuccess({
    required int super.wallId,
    required WallFeedAction super.action,
    super.feedId,
    super.feedList,
  });
}

class WallFeedFailure extends WallFeedState {
  final String message;

  const WallFeedFailure({
    required this.message,
    required int super.wallId,
    required WallFeedAction super.action,
    super.feedId,
  });

  @override
  List<Object?> get props => [message, wallId, action, feedId];
}
