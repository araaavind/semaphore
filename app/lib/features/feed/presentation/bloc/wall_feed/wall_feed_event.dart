part of 'wall_feed_bloc.dart';

abstract class WallFeedEvent extends Equatable {
  const WallFeedEvent();

  @override
  List<Object?> get props => [];
}

class AddFeedToWallRequested extends WallFeedEvent {
  final int feedId;
  final int wallId;

  const AddFeedToWallRequested({required this.feedId, required this.wallId});

  @override
  List<Object> get props => [feedId, wallId];
}

class RemoveFeedFromWallRequested extends WallFeedEvent {
  final int feedId;
  final int wallId;

  const RemoveFeedFromWallRequested(
      {required this.feedId, required this.wallId});

  @override
  List<Object> get props => [feedId, wallId];
}

class ListWallFeedsRequested extends WallFeedEvent {
  final int wallId;
  final String? searchKey;
  final String? searchValue;
  final int page;
  final int pageSize;
  final String? sortKey;

  const ListWallFeedsRequested({
    required this.wallId,
    this.searchKey,
    this.searchValue,
    this.page = 1,
    this.pageSize = ServerConstants.defaultPaginationPageSize,
    this.sortKey,
  });

  @override
  List<Object?> get props => [
        wallId,
        searchKey,
        searchValue,
        page,
        pageSize,
        sortKey,
      ];
}
