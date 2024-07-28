part of 'follow_feed_bloc.dart';

@immutable
sealed class FollowFeedEvent extends Equatable {}

enum FollowUnfollowAction { follow, unfollow }

class FollowUnfollowRequested extends FollowFeedEvent {
  final int feedId;
  final FollowUnfollowAction action;

  FollowUnfollowRequested(this.feedId, {required this.action});

  @override
  List<Object?> get props => [feedId, action];
}
