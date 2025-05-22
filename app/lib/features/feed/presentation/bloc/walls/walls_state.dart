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
  savePreference,
}

enum WallSortOption {
  hot,
  latest;

  String get name {
    switch (this) {
      case WallSortOption.hot:
        return 'Hot';
      case WallSortOption.latest:
        return 'Latest';
    }
  }

  String get code {
    switch (this) {
      case WallSortOption.hot:
        return 'hot';
      case WallSortOption.latest:
        return 'new';
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
  final int? pinnedWallId;
  final WallSortOption wallSort;
  final WallViewOption wallView;
  final String? message;
  final Map<String, String>? fieldErrors;
  final bool? refreshItems;

  const WallsState({
    this.status = WallStatus.initial,
    this.action,
    this.walls = const <Wall>[],
    this.currentWall,
    this.pinnedWallId,
    this.wallSort = WallSortOption.hot,
    this.wallView = WallViewOption.magazine,
    this.message,
    this.fieldErrors,
    this.refreshItems = false,
  });

  @override
  List<Object?> get props => [
        status,
        action,
        walls,
        currentWall,
        pinnedWallId,
        wallSort,
        wallView,
        message,
        fieldErrors,
        refreshItems,
      ];

  WallsState copyWith({
    WallStatus? status,
    WallAction? action,
    List<Wall>? walls,
    Wall? currentWall,
    int? pinnedWallId,
    WallSortOption? wallSort,
    WallViewOption? wallView,
    String? message,
    Map<String, String>? fieldErrors,
    bool? refreshItems,
  }) {
    return WallsState(
      status: status ?? this.status,
      action: action ?? this.action,
      walls: walls ?? this.walls,
      currentWall: currentWall ?? this.currentWall,
      pinnedWallId: pinnedWallId ?? this.pinnedWallId,
      wallSort: wallSort ?? this.wallSort,
      wallView: wallView ?? this.wallView,
      message: message ?? this.message,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      refreshItems: refreshItems ?? this.refreshItems,
    );
  }
}
