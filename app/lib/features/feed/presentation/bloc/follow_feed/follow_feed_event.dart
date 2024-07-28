part of 'follow_feed_bloc.dart';

@immutable
sealed class FollowFeedEvent extends Equatable {}

class FollowFeedRequested extends FollowFeedEvent {
  final int feedId;

  FollowFeedRequested(this.feedId);

  @override
  List<Object?> get props => [feedId];
}
