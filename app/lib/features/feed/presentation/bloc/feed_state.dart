part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, failure }

@immutable
class FeedState extends Equatable {
  final FeedStatus status;
  final FeedList feedList;
  final String? message;

  const FeedState({
    this.status = FeedStatus.initial,
    this.feedList = const FeedList(),
    this.message,
  });

  FeedState copyWith({
    FeedStatus? status,
    FeedList? feedList,
    bool? hasReachedMax,
    String? message,
  }) {
    return FeedState(
      status: status ?? this.status,
      feedList: feedList ?? this.feedList,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, feedList, message];
}
