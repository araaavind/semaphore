import 'package:app/core/services/analytics_service.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/core/utils/user_preferences_service.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/domain/usecases/create_wall.dart';
import 'package:app/features/feed/domain/usecases/delete_wall.dart';
import 'package:app/features/feed/domain/usecases/list_walls.dart';
import 'package:app/features/feed/domain/usecases/pin_wall.dart';
import 'package:app/features/feed/domain/usecases/unpin_wall.dart';
import 'package:app/features/feed/domain/usecases/update_wall.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'walls_event.dart';
part 'walls_state.dart';

class WallsBloc extends Bloc<WallsEvent, WallsState> {
  final ListWalls _listWalls;
  final CreateWall _createWall;
  final UpdateWall _updateWall;
  final DeleteWall _deleteWall;
  final PinWall _pinWall;
  final UnpinWall _unpinWall;
  final UserPreferencesService _userPreferencesService;

  WallsBloc({
    required ListWalls listWalls,
    required CreateWall createWall,
    required UpdateWall updateWall,
    required DeleteWall deleteWall,
    required PinWall pinWall,
    required UnpinWall unpinWall,
    required UserPreferencesService userPreferencesService,
  })  : _listWalls = listWalls,
        _createWall = createWall,
        _updateWall = updateWall,
        _deleteWall = deleteWall,
        _pinWall = pinWall,
        _unpinWall = unpinWall,
        _userPreferencesService = userPreferencesService,
        super(const WallsState()) {
    on<ListWallsRequested>(_onListWalls);
    on<SelectWallRequested>(_onSelectWall);
    on<ChangeWallOptions>(_onChangeWallSort);
    on<CreateWallRequested>(_onCreateWall);
    on<UpdateWallRequested>(_onUpdateWall);
    on<DeleteWallRequested>(_onDeleteWall);
    on<PinWallRequested>(_onPinWall);
    on<UnpinWallRequested>(_onUnpinWall);
    on<LoadDefaultPreferences>(_onLoadDefaultPreferences);
    on<SaveAsDefaultPreference>(_onSaveAsDefaultPreference);

    // Load default preferences on initialization
    add(LoadDefaultPreferences());
  }

  void _onListWalls(
    ListWallsRequested event,
    Emitter<WallsState> emit,
  ) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.list,
      refreshItems: event.refreshItems,
    ));
    final wallsRes = await _listWalls(NoParams());

    switch (wallsRes) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.list,
          message: l.message,
          refreshItems: event.refreshItems,
        ));
      case Right(value: final walls):
        Wall? currentWall;
        Wall? pinnedWall;
        if (state.currentWall != null) {
          currentWall = walls
              .firstWhere((element) => element.id == state.currentWall!.id);
        } else {
          try {
            pinnedWall = walls.firstWhere((element) => element.isPinned);
          } catch (e) {
            pinnedWall = null;
          }
          currentWall =
              pinnedWall ?? walls.firstWhere((element) => element.isPrimary);
        }
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.list,
          walls: walls,
          currentWall: currentWall,
          pinnedWallId: pinnedWall?.id,
          refreshItems: event.refreshItems,
        ));
    }
  }

  void _onCreateWall(
    CreateWallRequested event,
    Emitter<WallsState> emit,
  ) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.create,
    ));
    final res = await _createWall(event.wallName);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.create,
          message: l.message,
          fieldErrors: l.fieldErrors,
        ));
      case Right():
        // Track wall created event
        AnalyticsService.logWallCreated(event.wallName);
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.create,
        ));
    }
  }

  void _onUpdateWall(
    UpdateWallRequested event,
    Emitter<WallsState> emit,
  ) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.update,
    ));
    final res = await _updateWall(UpdateWallParams(
      wallId: event.wallId,
      wallName: event.wallName,
    ));
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.update,
          message: l.message,
          fieldErrors: l.fieldErrors,
        ));
      case Right():
        // Track wall updated event
        AnalyticsService.logWallUpdated('${event.wallId}');
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.update,
        ));
    }
  }

  void _onDeleteWall(
    DeleteWallRequested event,
    Emitter<WallsState> emit,
  ) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.delete,
    ));
    final res = await _deleteWall(event.wallId);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.delete,
          message: l.message,
        ));
      case Right():
        // Track wall removed event
        AnalyticsService.logWallRemoved('${event.wallId}');
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.delete,
        ));
    }
  }

  void _onSelectWall(
    SelectWallRequested event,
    Emitter<WallsState> emit,
  ) {
    // Track wall selected event
    AnalyticsService.logWallSelected('${event.selectedWall.id}');
    emit(state.copyWith(
      status: WallStatus.success,
      currentWall: event.selectedWall,
      action: WallAction.select,
    ));
  }

  void _onChangeWallSort(
    ChangeWallOptions event,
    Emitter<WallsState> emit,
  ) {
    emit(state.copyWith(
      status: WallStatus.success,
      wallSort: event.wallSort,
      wallView: event.wallView,
      action: WallAction.changeFilter,
    ));
  }

  void _onPinWall(
    PinWallRequested event,
    Emitter<WallsState> emit,
  ) async {
    final prevPinnedWallId = state.pinnedWallId;
    // Optimistically pin the wall and undo later if fails
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.pin,
      pinnedWallId: event.wallId,
    ));
    final res = await _pinWall(event.wallId);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.pin,
          pinnedWallId: prevPinnedWallId,
          message: l.message,
        ));
      case Right():
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.pin,
          pinnedWallId: event.wallId,
        ));
    }
  }

  void _onUnpinWall(
    UnpinWallRequested event,
    Emitter<WallsState> emit,
  ) async {
    final prevPinnedWallId = state.pinnedWallId;
    // Optimistically unpin the wall and undo later if fails
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.unpin,
      pinnedWallId: -1,
    ));
    final res = await _unpinWall(event.wallId);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.unpin,
          pinnedWallId: prevPinnedWallId,
          message: l.message,
        ));
      case Right():
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.unpin,
          pinnedWallId: -1,
        ));
    }
  }

  void _onLoadDefaultPreferences(
    LoadDefaultPreferences event,
    Emitter<WallsState> emit,
  ) {
    final defaultSort = _userPreferencesService.getDefaultWallSort();
    final defaultView = _userPreferencesService.getDefaultWallView();

    emit(state.copyWith(
      wallSort: defaultSort ?? state.wallSort,
      wallView: defaultView ?? state.wallView,
    ));
  }

  void _onSaveAsDefaultPreference(
    SaveAsDefaultPreference event,
    Emitter<WallsState> emit,
  ) async {
    if (event.sortOption != null) {
      await _userPreferencesService.setDefaultWallSort(event.sortOption!);
    }

    if (event.viewOption != null) {
      await _userPreferencesService.setDefaultWallView(event.viewOption!);
    }

    emit(state.copyWith(
      action: WallAction.savePreference,
    ));
  }
}
