part of 'saved_items_bloc.dart';

enum SavedItemsStatus { initial, loading, success, failure }

enum SavedItemsAction { save, unsave, list }

class SavedItemsState extends Equatable {
  final SavedItemsStatus status;
  final SavedItemsAction action;
  final SavedItemList savedItemList;
  final String? message;
  final int? currentItemId;
  final bool refresh;

  const SavedItemsState({
    this.status = SavedItemsStatus.initial,
    this.action = SavedItemsAction.list,
    this.savedItemList = const SavedItemList(),
    this.message,
    this.currentItemId,
    this.refresh = true,
  });

  SavedItemsState copyWith({
    SavedItemsStatus? status,
    SavedItemsAction? action,
    SavedItemList? savedItemList,
    String? message,
    int? currentItemId,
    bool? refresh,
  }) {
    return SavedItemsState(
      status: status ?? this.status,
      action: action ?? this.action,
      savedItemList: savedItemList ?? this.savedItemList,
      message: message ?? this.message,
      currentItemId: currentItemId ?? this.currentItemId,
      refresh: refresh ?? this.refresh,
    );
  }

  @override
  List<Object?> get props => [
        status,
        action,
        savedItemList,
        message,
        currentItemId,
        refresh,
      ];
}
