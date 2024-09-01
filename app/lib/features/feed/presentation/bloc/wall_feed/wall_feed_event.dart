part of 'wall_feed_bloc.dart';

abstract class WallFeedEvent extends Equatable {
  const WallFeedEvent();

  @override
  List<Object> get props => [];
}

class AddFeedToWallRequested extends WallFeedEvent {
  final int feedId;
  final int wallId;

  const AddFeedToWallRequested({required this.feedId, required this.wallId});

  @override
  List<Object> get props => [feedId, wallId];
}

class RemoveFeedFromWallRequested extends WallFeedEvent {
  final int feedId;
  final int wallId;

  const RemoveFeedFromWallRequested(
      {required this.feedId, required this.wallId});

  @override
  List<Object> get props => [feedId, wallId];
}
