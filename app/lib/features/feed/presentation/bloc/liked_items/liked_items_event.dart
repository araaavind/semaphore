part of 'liked_items_bloc.dart';

@immutable
sealed class LikedItemsEvent extends Equatable {}

class LikeItemRequested extends LikedItemsEvent {
  final int itemId;

  LikeItemRequested(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class UnlikeItemRequested extends LikedItemsEvent {
  final int itemId;
  final bool refresh;

  UnlikeItemRequested({
    required this.itemId,
    this.refresh = false,
  });

  @override
  List<Object> get props => [itemId, refresh];
}
