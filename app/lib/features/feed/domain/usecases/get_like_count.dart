import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetLikeCount implements Usecase<int, int> {
  FeedRepository feedRepository;
  GetLikeCount(this.feedRepository);

  @override
  Future<Either<Failure, int>> call(int itemId) async {
    return await feedRepository.getLikeCount(itemId);
  }
}
