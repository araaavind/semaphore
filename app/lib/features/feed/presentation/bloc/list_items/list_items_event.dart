part of 'list_items_bloc.dart';

@immutable
sealed class ListItemsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListItemsRequested extends ListItemsEvent {
  final int wallId;
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  ListItemsRequested({
    required this.wallId,
    this.searchKey,
    this.searchValue,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });

  @override
  List<Object?> get props => super.props
    ..addAll([
      wallId,
      searchKey,
      searchValue,
      page,
      pageSize,
      sortKey,
    ]);
}
