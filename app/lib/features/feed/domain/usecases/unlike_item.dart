import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnlikeItem {
  final FeedRepository repository;

  UnlikeItem(this.repository);

  Future<Either<Failure, void>> call(int itemId) async {
    return await repository.unlikeItem(itemId);
  }
}
