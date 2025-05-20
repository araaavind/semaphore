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
  final String after;
  final int pageSize;
  final String? sortMode;

  ListItemsRequested({
    required this.parentId,
    required this.parentType,
    this.searchKey,
    this.searchValue,
    this.after = '',
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortMode,
  });

  @override
  List<Object?> get props => super.props
    ..addAll([
      parentId,
      parentType,
      searchKey,
      searchValue,
      after,
      pageSize,
      sortMode,
    ]);
}
