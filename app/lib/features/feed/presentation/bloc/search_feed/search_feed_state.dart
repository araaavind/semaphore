part of 'search_feed_bloc.dart';

enum SearchFeedStatus { initial, loading, success, failure }

@immutable
class SearchFeedState extends Equatable {
  final SearchFeedStatus status;
  final FeedList feedList;
  final String? message;

  const SearchFeedState({
    this.status = SearchFeedStatus.initial,
    this.feedList = const FeedList(),
    this.message,
  });

  SearchFeedState copyWith({
    SearchFeedStatus? status,
    FeedList? feedList,
    bool? hasReachedMax,
    String? message,
  }) {
    return SearchFeedState(
      status: status ?? this.status,
      feedList: feedList ?? this.feedList,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, feedList, message];
}
