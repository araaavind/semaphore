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

class AddFollowRequested extends FollowFeedEvent {
  final String feedUrl;
  final String? feedType;

  AddFollowRequested(this.feedUrl, {this.feedType});

  @override
  List<Object?> get props => [feedUrl, feedType];
}
