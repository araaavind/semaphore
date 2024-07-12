part of 'feed_bloc.dart';

@immutable
sealed class FeedState {}

final class FeedInitial extends FeedState {}

final class FeedLoading extends FeedState {}

final class FeedListFetched extends FeedState {
  final FeedList feedList;

  FeedListFetched(this.feedList);
}

final class FeedFailed extends FeedState {
  final String message;

  FeedFailed(this.message);
}
