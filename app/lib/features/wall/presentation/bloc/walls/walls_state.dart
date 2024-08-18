part of 'walls_bloc.dart';

enum WallsStatus { initial, loading, success, failure }

class WallsState extends Equatable {
  final WallsStatus status;
  final List<Wall> walls;
  final Wall? currentWall;
  final String? message;

  const WallsState({
    this.status = WallsStatus.initial,
    this.walls = const <Wall>[],
    this.currentWall,
    this.message,
  });

  @override
  List<Object?> get props => [status, walls, currentWall, message];

  WallsState copyWith({
    WallsStatus? status,
    List<Wall>? walls,
    Wall? currentWall,
    String? message,
  }) {
    return WallsState(
      status: status ?? this.status,
      walls: walls ?? this.walls,
      currentWall: currentWall ?? this.currentWall,
      message: message ?? this.message,
    );
  }
}
