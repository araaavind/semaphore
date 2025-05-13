import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckUserSavedItems implements Usecase<List<bool>, List<int>> {
  FeedRepository feedRepository;
  CheckUserSavedItems(this.feedRepository);

  @override
  Future<Either<Failure, List<bool>>> call(List<int> itemIds) async {
    return await feedRepository.checkUserSavedItems(itemIds);
  }
}
