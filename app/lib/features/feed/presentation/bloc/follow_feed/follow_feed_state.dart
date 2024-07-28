part of 'follow_feed_bloc.dart';

enum FollowFeedStatus { unfollowed, loading, followed, failure }

@immutable
class FollowFeedState extends Equatable {
  final FollowFeedStatus status;
  final int? feedId;
  final String? message;

  const FollowFeedState({
    required this.status,
    this.feedId,
    this.message,
  });

  FollowFeedState copyWith({
    FollowFeedStatus? status,
    int? feedId,
    String? message,
  }) {
    return FollowFeedState(
      status: status ?? this.status,
      feedId: feedId ?? this.feedId,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, feedId, message];
}
