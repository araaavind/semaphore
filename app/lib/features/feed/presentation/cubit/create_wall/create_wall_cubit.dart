import 'package:app/features/feed/domain/usecases/create_wall.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'create_wall_state.dart';

class CreateWallCubit extends Cubit<CreateWallState> {
  final CreateWall _createWall;

  CreateWallCubit({
    required CreateWall createWall,
  })  : _createWall = createWall,
        super(
          const CreateWallState(status: CreateWallStatus.initial),
        );

  Future<void> createWall(String wallName) async {
    emit(state.copyWith(status: CreateWallStatus.loading));
    final res = await _createWall(wallName);
    switch (res) {
      case Left(value: final l):
        emit(state.copyWith(
          status: CreateWallStatus.failure,
          message: l.message,
          fieldErrors: l.fieldErrors,
        ));
      case Right():
        emit(state.copyWith(
          status: CreateWallStatus.success,
        ));
    }
  }
}
