part of 'walls_bloc.dart';

@immutable
sealed class WallsEvent extends Equatable {}

class ListWallsRequested extends WallsEvent {
  @override
  List<Object?> get props => [];
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
