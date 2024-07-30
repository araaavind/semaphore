import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddFollowFeed implements Usecase<void, String> {
  FeedRepository feedRepository;
  AddFollowFeed(this.feedRepository);

  @override
  Future<Either<Failure, void>> call(String feedUrl) async {
    return await feedRepository.addAndFollowFeed(feedUrl);
  }
}
