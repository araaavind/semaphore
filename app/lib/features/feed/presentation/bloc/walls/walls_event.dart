part of 'walls_bloc.dart';

@immutable
sealed class WallsEvent extends Equatable {}

class ListWallsRequested extends WallsEvent {
  final bool refreshItems;

  ListWallsRequested({required this.refreshItems});

  @override
  List<Object?> get props => [refreshItems];
}

class SelectWallRequested extends WallsEvent {
  final Wall selectedWall;

  SelectWallRequested({required this.selectedWall});

  @override
  List<Object?> get props => [selectedWall];
}

class ChangeWallOptions extends WallsEvent {
  final WallSortOption? wallSort;
  final WallViewOption? wallView;

  ChangeWallOptions({
    this.wallSort,
    this.wallView,
  });

  @override
  List<Object?> get props => [wallSort, wallView];
}

class CreateWallRequested extends WallsEvent {
  final String wallName;

  CreateWallRequested({required this.wallName});

  @override
  List<Object?> get props => [wallName];
}

class UpdateWallRequested extends WallsEvent {
  final int wallId;
  final String wallName;

  UpdateWallRequested({required this.wallId, required this.wallName});

  @override
  List<Object?> get props => [wallId, wallName];
}

class DeleteWallRequested extends WallsEvent {
  final int wallId;

  DeleteWallRequested({required this.wallId});

  @override
  List<Object?> get props => [wallId];
}

class PinWallRequested extends WallsEvent {
  final int wallId;

  PinWallRequested({required this.wallId});

  @override
  List<Object?> get props => [wallId];
}

class UnpinWallRequested extends WallsEvent {
  final int wallId;

  UnpinWallRequested({required this.wallId});

  @override
  List<Object?> get props => [wallId];
}

class LoadDefaultPreferences extends WallsEvent {
  @override
  List<Object?> get props => [];
}

class SaveAsDefaultPreference extends WallsEvent {
  final WallSortOption? sortOption;
  final WallViewOption? viewOption;

  SaveAsDefaultPreference({
    this.sortOption,
    this.viewOption,
  });

  @override
  List<Object?> get props => [sortOption, viewOption];
}
