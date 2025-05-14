part of 'saved_items_bloc.dart';

@immutable
sealed class SavedItemsEvent extends Equatable {}

class ListSavedItemsRequested extends SavedItemsEvent {
  final int page;
  final int pageSize;
  final String? title;
  final String? sortKey;

  ListSavedItemsRequested({
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.title,
    this.sortKey,
  });

  @override
  List<Object?> get props => [page, pageSize, title, sortKey];
}

class SaveItemRequested extends SavedItemsEvent {
  final int itemId;

  SaveItemRequested(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class UnsaveItemRequested extends SavedItemsEvent {
  final int itemId;
  final bool refresh;

  UnsaveItemRequested({
    required this.itemId,
    this.refresh = false,
  });

  @override
  List<Object> get props => [itemId, refresh];
}
