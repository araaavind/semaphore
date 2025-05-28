import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListTopics implements Usecase<List<Topic>, bool> {
  FeedRepository feedRepository;
  ListTopics(this.feedRepository);

  @override
  Future<Either<Failure, List<Topic>>> call(bool fromLocal) async {
    if (fromLocal) {
      return await feedRepository.listSavedTopics();
    }
    return await feedRepository.listTopics();
  }
}
