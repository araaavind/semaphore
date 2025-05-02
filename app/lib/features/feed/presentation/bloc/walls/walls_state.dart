part of 'walls_bloc.dart';

enum WallStatus { initial, loading, success, failure }

enum WallAction {
  list,
  select,
  changeFilter,
  create,
  update,
  delete,
  pin,
  unpin,
}

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
  card,
  text;

  String get name {
    switch (this) {
      case WallViewOption.magazine:
        return 'Magazine View';
      case WallViewOption.card:
        return 'Card View';
      case WallViewOption.text:
        return 'Text Only';
    }
  }
}

class WallsState extends Equatable {
  final WallStatus status;
  final WallAction? action;
  final List<Wall> walls;
  final Wall? currentWall;
  final Wall? pinnedWall;
  final WallSortOption wallSort;
  final WallViewOption wallView;
  final String? message;
  final Map<String, String>? fieldErrors;

  const WallsState({
    this.status = WallStatus.initial,
    this.action,
    this.walls = const <Wall>[],
    this.currentWall,
    this.pinnedWall,
    this.wallSort = WallSortOption.latest,
    this.wallView = WallViewOption.magazine,
    this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [
        status,
        action,
        walls,
        currentWall,
        pinnedWall,
        wallSort,
        wallView,
        message,
        fieldErrors,
      ];

  WallsState copyWith({
    WallStatus? status,
    WallAction? action,
    List<Wall>? walls,
    Wall? currentWall,
    Wall? pinnedWall,
    WallSortOption? wallSort,
    WallViewOption? wallView,
    String? message,
    Map<String, String>? fieldErrors,
  }) {
    return WallsState(
      status: status ?? this.status,
      action: action ?? this.action,
      walls: walls ?? this.walls,
      currentWall: currentWall ?? this.currentWall,
      pinnedWall: pinnedWall ?? this.pinnedWall,
      wallSort: wallSort ?? this.wallSort,
      wallView: wallView ?? this.wallView,
      message: message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
