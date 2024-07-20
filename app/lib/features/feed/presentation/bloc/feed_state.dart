part of 'feed_bloc.dart';

enum FeedStatus { initial, success, failure }

@immutable
class FeedState extends Equatable {
  final FeedStatus status;
  final FeedList feedList;
  final bool hasReachedMax;

  const FeedState({
    this.status = FeedStatus.initial,
    this.feedList = const FeedList(),
    this.hasReachedMax = false,
  });

  FeedState copyWith({
    FeedStatus? status,
    FeedList? feedList,
    bool? hasReachedMax,
  }) {
    return FeedState(
      status: status ?? this.status,
      feedList: feedList ?? this.feedList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, feedList, hasReachedMax];
}
