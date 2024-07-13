part of 'feed_bloc.dart';

@immutable
sealed class FeedState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FeedInitial extends FeedState {}

final class FeedLoading extends FeedState {}

final class FeedListFetched extends FeedState {
  final FeedList feedList;

  FeedListFetched(this.feedList);

  @override
  List<Object?> get props => super.props..add(feedList);
}

final class FeedFailed extends FeedState {
  final String message;

  FeedFailed(this.message);

  @override
  List<Object?> get props => super.props..add(message);
}
