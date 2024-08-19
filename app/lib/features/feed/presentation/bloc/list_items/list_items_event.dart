part of 'list_items_bloc.dart';

enum ListItemsParentType { feed, wall }

@immutable
sealed class ListItemsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListItemsRequested extends ListItemsEvent {
  final int parentId;
  final ListItemsParentType parentType;
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  ListItemsRequested({
    required this.parentId,
    required this.parentType,
    this.searchKey,
    this.searchValue,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });

  @override
  List<Object?> get props => super.props
    ..addAll([
      parentId,
      parentType,
      searchKey,
      searchValue,
      page,
      pageSize,
      sortKey,
    ]);
}
