part of 'liked_items_bloc.dart';

enum LikedItemsStatus { initial, loading, success, failure }

enum LikedItemsAction { none, like, unlike }

class LikedItemsState extends Equatable {
  final LikedItemsStatus status;
  final LikedItemsAction action;
  final String? message;
  final int? currentItemId;
  final bool refresh;

  const LikedItemsState({
    this.status = LikedItemsStatus.initial,
    this.action = LikedItemsAction.none,
    this.message,
    this.currentItemId,
    this.refresh = false,
  });

  LikedItemsState copyWith({
    LikedItemsStatus? status,
    LikedItemsAction? action,
    String? message,
    int? currentItemId,
    bool? refresh,
  }) {
    return LikedItemsState(
      status: status ?? this.status,
      action: action ?? this.action,
      message: message ?? this.message,
      currentItemId: currentItemId ?? this.currentItemId,
      refresh: refresh ?? this.refresh,
    );
  }

  @override
  List<Object?> get props => [
        status,
        action,
        message,
        currentItemId,
        refresh,
      ];
}
