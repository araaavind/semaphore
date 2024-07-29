part of 'list_followers_bloc.dart';

@immutable
sealed class ListFollowersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListFollowersRequested extends ListFollowersEvent {
  final int feedId;
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  ListFollowersRequested({
    required this.feedId,
    this.searchKey,
    this.searchValue,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });

  @override
  List<Object?> get props => super.props
    ..addAll([
      feedId,
      searchKey,
      searchValue,
      page,
      pageSize,
      sortKey,
    ]);
}
