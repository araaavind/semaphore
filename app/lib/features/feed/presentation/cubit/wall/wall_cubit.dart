import 'package:app/features/feed/domain/usecases/create_wall.dart';
import 'package:app/features/feed/domain/usecases/delete_wall.dart';
import 'package:app/features/feed/domain/usecases/pin_wall.dart';
import 'package:app/features/feed/domain/usecases/unpin_wall.dart';
import 'package:app/features/feed/domain/usecases/update_wall.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'wall_state.dart';

class WallCubit extends Cubit<WallState> {
  final CreateWall _createWall;
  final UpdateWall _updateWall;
  final DeleteWall _deleteWall;
  final PinWall _pinWall;
  final UnpinWall _unpinWall;

  WallCubit({
    required CreateWall createWall,
    required UpdateWall updateWall,
    required DeleteWall deleteWall,
    required PinWall pinWall,
    required UnpinWall unpinWall,
  })  : _createWall = createWall,
        _updateWall = updateWall,
        _deleteWall = deleteWall,
        _pinWall = pinWall,
        _unpinWall = unpinWall,
        super(
          const WallState(status: WallStatus.initial),
        );

  Future<void> createWall(String wallName) async {
    emit(state.copyWith(status: WallStatus.loading, action: WallAction.create));
    final res = await _createWall(wallName);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.create,
          message: l.message,
          fieldErrors: l.fieldErrors,
        ));
      case Right():
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.create,
        ));
    }
  }

  Future<void> updateWall(int wallId, String wallName) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.update,
    ));
    final res = await _updateWall(UpdateWallParams(
      wallId: wallId,
      wallName: wallName,
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
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.update,
        ));
    }
  }

  Future<void> deleteWall(int wallId) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.delete,
    ));
    final res = await _deleteWall(wallId);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.delete,
          message: l.message,
        ));
      case Right():
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.delete,
        ));
    }
  }

  Future<void> pinWall(int wallId) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.pin,
    ));
    final res = await _pinWall(wallId);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.pin,
          message: l.message,
        ));
      case Right():
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.pin,
        ));
    }
  }

  Future<void> unpinWall(int wallId) async {
    emit(state.copyWith(
      status: WallStatus.loading,
      action: WallAction.unpin,
    ));
    final res = await _unpinWall(wallId);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: WallStatus.failure,
          action: WallAction.unpin,
          message: l.message,
        ));
      case Right():
        emit(state.copyWith(
          status: WallStatus.success,
          action: WallAction.unpin,
        ));
    }
  }
}
