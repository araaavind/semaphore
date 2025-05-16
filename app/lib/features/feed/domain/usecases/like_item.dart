import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class LikeItem {
  final FeedRepository repository;

  LikeItem(this.repository);

  Future<Either<Failure, void>> call(int itemId) async {
    return await repository.likeItem(itemId);
  }
}
