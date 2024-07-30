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

  const AddFollowFeedState({
    required this.status,
    this.message,
    this.fieldErrors,
  });

  AddFollowFeedState copyWith({
    FollowFeedStatus? status,
    int? feedId,
    String? message,
    Map<String, String>? fieldErrors,
  }) {
    return AddFollowFeedState(
      status: status ?? this.status,
      message: message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [status, message, fieldErrors];
}
