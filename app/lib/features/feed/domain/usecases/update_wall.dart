import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateWallParams {
  final int wallId;
  final String wallName;

  UpdateWallParams({required this.wallId, required this.wallName});
}

class UpdateWall implements Usecase<Wall, UpdateWallParams> {
  FeedRepository feedRepository;
  UpdateWall(this.feedRepository);

  @override
  Future<Either<Failure, Wall>> call(UpdateWallParams params) async {
    return await feedRepository.updateWall(
      params.wallId,
      params.wallName,
    );
  }
}
