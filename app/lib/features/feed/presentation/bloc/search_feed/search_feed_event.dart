part of 'search_feed_bloc.dart';

@immutable
sealed class SearchFeedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedSearchRequested extends SearchFeedEvent {
  final String? searchKey;
  final String? searchValue;
  final int? topicId;
  final int page;
  final int pageSize;
  final String? sortKey;
  final ListFeedsType type;

  FeedSearchRequested({
    this.searchKey,
    this.searchValue,
    this.topicId,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
    this.type = ListFeedsType.all,
  });

  @override
  List<Object?> get props => super.props
    ..addAll([
      searchKey,
      searchValue,
      topicId,
      page,
      pageSize,
      sortKey,
      type,
    ]);
}
