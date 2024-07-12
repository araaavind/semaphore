part of 'feed_bloc.dart';

@immutable
sealed class FeedEvent {}

class FeedListFeedsEvent extends FeedEvent {
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  FeedListFeedsEvent({
    this.searchKey,
    this.searchValue,
    this.page = ServerConstants.defaultPaginationPage,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });
}
