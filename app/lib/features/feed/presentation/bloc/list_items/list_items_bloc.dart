import 'package:app/core/constants/server_constants.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/usecases/list_items.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'list_items_event.dart';
part 'list_items_state.dart';

class ListItemsBloc extends Bloc<ListItemsEvent, ListItemsState> {
  final ListItems _listItems;

  ListItemsBloc({
    required ListItems listItems,
  })  : _listItems = listItems,
        super(const ListItemsState()) {
    on<ListItemsRequested>(
      _onListItemsRequested,
    );
  }

  void _onListItemsRequested(
    ListItemsRequested event,
    Emitter<ListItemsState> emit,
  ) async {
    emit(state.copyWith(status: ListItemsStatus.loading));
    final itemsRes = await _listItems(
      ListItemsParams(
        parentId: event.parentId,
        parentType: event.parentType,
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        sortMode: event.sortMode,
        after: event.after,
        pageSize: event.pageSize,
        sessionId: event.sessionId,
      ),
    );

    switch (itemsRes) {
      case Left(value: final l):
        emit(state.copyWith(
          status: ListItemsStatus.failure,
          message: l.message,
        ));
      case Right(value: final itemsList):
        emit(state.copyWith(
          status: ListItemsStatus.success,
          itemList: itemsList,
        ));
    }
  }
}
