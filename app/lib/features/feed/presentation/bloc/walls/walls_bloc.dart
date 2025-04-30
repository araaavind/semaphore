import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/domain/usecases/list_walls.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'walls_event.dart';
part 'walls_state.dart';

class WallsBloc extends Bloc<WallsEvent, WallsState> {
  final ListWalls _listWalls;

  WallsBloc({
    required ListWalls listWalls,
  })  : _listWalls = listWalls,
        super(const WallsState()) {
    on<ListWallsRequested>(_onListWalls);
    on<SelectWallRequested>(_onSelectWall);
    on<ChangeWallOptions>(_onChangeWallSort);
  }

  void _onListWalls(
    ListWallsRequested event,
    Emitter<WallsState> emit,
  ) async {
    emit(state.copyWith(status: WallsStatus.loading));
    final wallsRes = await _listWalls(NoParams());

    switch (wallsRes) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallsStatus.failure,
          message: l.message,
        ));
      case Right(value: final walls):
        Wall? currentWall;
        if (state.currentWall != null) {
          currentWall = walls
              .firstWhere((element) => element.id == state.currentWall!.id);
        } else {
          currentWall = walls.firstWhere((element) => element.isPrimary);
        }
        emit(state.copyWith(
          status: WallsStatus.success,
          walls: walls,
          currentWall: currentWall,
        ));
    }
  }

  void _onSelectWall(
    SelectWallRequested event,
    Emitter<WallsState> emit,
  ) {
    emit(state.copyWith(
      currentWall: event.selectedWall,
    ));
  }

  void _onChangeWallSort(
    ChangeWallOptions event,
    Emitter<WallsState> emit,
  ) {
    emit(state.copyWith(
      wallSort: event.wallSort,
      wallView: event.wallView,
    ));
  }
}
