part of 'feed_bloc.dart';

@immutable
sealed class FeedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedSearchRequested extends FeedEvent {
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  FeedSearchRequested({
    this.searchKey,
    this.searchValue,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });

  @override
  List<Object?> get props => super.props
    ..addAll([
      searchKey,
      searchValue,
      page,
      pageSize,
      sortKey,
    ]);
}
