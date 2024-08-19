import 'package:app/core/constants/server_constants.dart';
import 'package:app/features/feed/domain/entities/item_list.dart';
import 'package:app/features/feed/domain/usecases/list_wall_items.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'list_items_event.dart';
part 'list_items_state.dart';

class ListItemsBloc extends Bloc<ListItemsEvent, ListItemsState> {
  final ListWallItems _listWallItems;

  ListItemsBloc({
    required ListWallItems listWallItems,
  })  : _listWallItems = listWallItems,
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
    final itemsRes = await _listWallItems(
      ListWallItemsParams(
        wallId: event.wallId,
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        sortKey: event.sortKey,
        page: event.page,
        pageSize: event.pageSize,
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
