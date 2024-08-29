import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveFeedFromWallParams {
  final int feedId;
  final int wallId;

  RemoveFeedFromWallParams({required this.feedId, required this.wallId});
}

class RemoveFeedFromWall implements Usecase<void, RemoveFeedFromWallParams> {
  FeedRepository feedRepository;
  RemoveFeedFromWall(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(RemoveFeedFromWallParams params) async {
    return await feedRepository.removeFeedFromWall(
      params.feedId,
      params.wallId,
    );
  }
}
