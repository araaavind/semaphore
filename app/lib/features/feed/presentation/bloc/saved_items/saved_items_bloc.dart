import 'package:app/core/constants/constants.dart';
import 'package:app/features/feed/domain/entities/saved_item_list.dart';
import 'package:app/features/feed/domain/usecases/get_saved_items.dart';
import 'package:app/features/feed/domain/usecases/save_item.dart';
import 'package:app/features/feed/domain/usecases/unsave_item.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'saved_items_event.dart';
part 'saved_items_state.dart';

class SavedItemsBloc extends Bloc<SavedItemsEvent, SavedItemsState> {
  final SaveItem _saveItem;
  final UnsaveItem _unsaveItem;
  final GetSavedItems _getSavedItems;

  SavedItemsBloc({
    required SaveItem saveItem,
    required UnsaveItem unsaveItem,
    required GetSavedItems getSavedItems,
  })  : _saveItem = saveItem,
        _unsaveItem = unsaveItem,
        _getSavedItems = getSavedItems,
        super(const SavedItemsState()) {
    on<ListSavedItemsRequested>(_onListSavedItemsRequested);
    on<SaveItemRequested>(_onSaveItemRequested);
    on<UnsaveItemRequested>(_onUnsaveItemRequested);
  }

  Future<void> _onListSavedItemsRequested(
    ListSavedItemsRequested event,
    Emitter<SavedItemsState> emit,
  ) async {
    emit(state.copyWith(
      status: SavedItemsStatus.loading,
      action: SavedItemsAction.list,
    ));

    final res = await _getSavedItems(
      GetSavedItemsParams(
        page: event.page,
        pageSize: event.pageSize,
        searchValue: event.title,
        sortKey: event.sortKey,
      ),
    );

    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: SavedItemsStatus.failure,
          action: SavedItemsAction.list,
          message: l.message,
        ));
      case Right(value: final savedItemList):
        emit(state.copyWith(
          status: SavedItemsStatus.success,
          action: SavedItemsAction.list,
          savedItemList: savedItemList,
        ));
    }
  }

  Future<void> _onSaveItemRequested(
    SaveItemRequested event,
    Emitter<SavedItemsState> emit,
  ) async {
    emit(state.copyWith(
      status: SavedItemsStatus.loading,
      action: SavedItemsAction.save,
      currentItemId: event.itemId,
    ));

    final res = await _saveItem(event.itemId);

    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: SavedItemsStatus.failure,
          action: SavedItemsAction.save,
          currentItemId: event.itemId,
          message: l.message,
        ));
      case Right(value: final _):
        emit(state.copyWith(
          status: SavedItemsStatus.success,
          action: SavedItemsAction.save,
          currentItemId: event.itemId,
        ));
    }
  }

  Future<void> _onUnsaveItemRequested(
    UnsaveItemRequested event,
    Emitter<SavedItemsState> emit,
  ) async {
    emit(state.copyWith(
      status: SavedItemsStatus.loading,
      action: SavedItemsAction.unsave,
      currentItemId: event.itemId,
    ));

    final res = await _unsaveItem(event.itemId);

    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: SavedItemsStatus.failure,
          action: SavedItemsAction.unsave,
          currentItemId: event.itemId,
          message: l.message,
        ));
      case Right(value: final _):
        emit(state.copyWith(
          status: SavedItemsStatus.success,
          action: SavedItemsAction.unsave,
          currentItemId: event.itemId,
        ));
    }
  }
}
