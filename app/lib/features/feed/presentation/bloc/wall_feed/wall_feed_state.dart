part of 'wall_feed_bloc.dart';

abstract class WallFeedState extends Equatable {
  final int? wallId;

  const WallFeedState({this.wallId});

  @override
  List<Object?> get props => [wallId];
}

class WallFeedInitial extends WallFeedState {}

class WallFeedLoading extends WallFeedState {
  const WallFeedLoading({required int wallId}) : super(wallId: wallId);
}

class WallFeedSuccess extends WallFeedState {
  const WallFeedSuccess({required int wallId}) : super(wallId: wallId);
}

class WallFeedFailure extends WallFeedState {
  final String message;

  const WallFeedFailure({required this.message, required int wallId})
      : super(wallId: wallId);

  @override
  List<Object?> get props => [message, wallId];
}
