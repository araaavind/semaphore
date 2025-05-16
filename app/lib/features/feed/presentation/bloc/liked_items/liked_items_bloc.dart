import 'package:app/features/feed/domain/usecases/like_item.dart';
import 'package:app/features/feed/domain/usecases/unlike_item.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'liked_items_event.dart';
part 'liked_items_state.dart';

class LikedItemsBloc extends Bloc<LikedItemsEvent, LikedItemsState> {
  final LikeItem _likeItem;
  final UnlikeItem _unlikeItem;

  LikedItemsBloc({
    required LikeItem likeItem,
    required UnlikeItem unlikeItem,
  })  : _likeItem = likeItem,
        _unlikeItem = unlikeItem,
        super(const LikedItemsState()) {
    on<LikeItemRequested>(_onLikeItemRequested);
    on<UnlikeItemRequested>(_onUnlikeItemRequested);
  }

  Future<void> _onLikeItemRequested(
    LikeItemRequested event,
    Emitter<LikedItemsState> emit,
  ) async {
    emit(state.copyWith(
      status: LikedItemsStatus.loading,
      action: LikedItemsAction.like,
      currentItemId: event.itemId,
    ));

    final res = await _likeItem(event.itemId);

    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: LikedItemsStatus.failure,
          action: LikedItemsAction.like,
          currentItemId: event.itemId,
          message: l.message,
        ));
      case Right(value: final _):
        emit(state.copyWith(
          status: LikedItemsStatus.success,
          action: LikedItemsAction.like,
          currentItemId: event.itemId,
        ));
    }
  }

  Future<void> _onUnlikeItemRequested(
    UnlikeItemRequested event,
    Emitter<LikedItemsState> emit,
  ) async {
    emit(state.copyWith(
      status: LikedItemsStatus.loading,
      action: LikedItemsAction.unlike,
      currentItemId: event.itemId,
    ));

    final res = await _unlikeItem(event.itemId);

    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: LikedItemsStatus.failure,
          action: LikedItemsAction.unlike,
          currentItemId: event.itemId,
          message: l.message,
        ));
      case Right(value: final _):
        emit(state.copyWith(
          status: LikedItemsStatus.success,
          action: LikedItemsAction.unlike,
          currentItemId: event.itemId,
          refresh: event.refresh,
        ));
    }
  }
}
