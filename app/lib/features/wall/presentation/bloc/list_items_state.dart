part of 'list_items_bloc.dart';

enum ListItemsStatus { initial, loading, success, failure }

@immutable
class ListItemsState extends Equatable {
  final ListItemsStatus status;
  final ItemList itemList;
  final String? message;

  const ListItemsState({
    this.status = ListItemsStatus.initial,
    this.itemList = const ItemList(),
    this.message,
  });

  ListItemsState copyWith({
    ListItemsStatus? status,
    ItemList? itemList,
    String? message,
  }) {
    return ListItemsState(
      status: status ?? this.status,
      itemList: itemList ?? this.itemList,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, itemList, message];
}
