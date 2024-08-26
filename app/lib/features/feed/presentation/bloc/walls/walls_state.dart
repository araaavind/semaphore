part of 'walls_bloc.dart';

enum WallsStatus { initial, loading, success, failure }

enum WallSortOption {
  hot,
  latest,
  trending,
  top;

  String get name {
    switch (this) {
      case WallSortOption.hot:
        return 'Hot';
      case WallSortOption.latest:
        return 'Latest';
      case WallSortOption.trending:
        return 'Trending';
      case WallSortOption.top:
        return 'Top';
    }
  }
}

enum WallViewOption {
  magazine,
  card;

  String get name {
    switch (this) {
      case WallViewOption.magazine:
        return 'Magazine View';
      case WallViewOption.card:
        return 'Card View';
    }
  }
}

class WallsState extends Equatable {
  final WallsStatus status;
  final List<Wall> walls;
  final Wall? currentWall;
  final WallSortOption wallSort;
  final WallViewOption wallView;
  final String? message;

  const WallsState({
    this.status = WallsStatus.initial,
    this.walls = const <Wall>[],
    this.currentWall,
    this.wallSort = WallSortOption.latest,
    this.wallView = WallViewOption.magazine,
    this.message,
  });

  @override
  List<Object?> get props =>
      [status, walls, currentWall, wallSort, wallView, message];

  WallsState copyWith({
    WallsStatus? status,
    List<Wall>? walls,
    Wall? currentWall,
    WallSortOption? wallSort,
    WallViewOption? wallView,
    String? message,
  }) {
    return WallsState(
      status: status ?? this.status,
      walls: walls ?? this.walls,
      currentWall: currentWall ?? this.currentWall,
      wallSort: wallSort ?? this.wallSort,
      wallView: wallView ?? this.wallView,
      message: message ?? this.message,
    );
  }
}
