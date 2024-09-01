part of 'follow_feed_bloc.dart';

enum FollowFeedStatus { initial, unfollowed, loading, followed, failure }

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

class AddFollowFeedState extends Equatable {
  final FollowFeedStatus status;
  final String? message;
  final Map<String, String>? fieldErrors;
  final int? feedId;

  const AddFollowFeedState({
    required this.status,
    this.message,
    this.fieldErrors,
    this.feedId,
  });

  AddFollowFeedState copyWith({
    FollowFeedStatus? status,
    String? message,
    Map<String, String>? fieldErrors,
    int? feedId,
  }) {
    return AddFollowFeedState(
      status: status ?? this.status,
      message: message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      feedId: feedId ?? this.feedId,
    );
  }

  @override
  List<Object?> get props => [status, message, fieldErrors, feedId];
}
