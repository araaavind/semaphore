import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddFeedToWallParams {
  final int feedId;
  final int wallId;

  AddFeedToWallParams({required this.feedId, required this.wallId});
}

class AddFeedToWall implements Usecase<void, AddFeedToWallParams> {
  FeedRepository feedRepository;
  AddFeedToWall(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(AddFeedToWallParams params) async {
    return await feedRepository.addFeedToWall(params.feedId, params.wallId);
  }
}
