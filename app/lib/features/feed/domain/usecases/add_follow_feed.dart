import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddFollowFeedParams {
  final String feedUrl;
  final String? feedType;

  AddFollowFeedParams({required this.feedUrl, this.feedType});
}

class AddFollowFeed implements Usecase<void, AddFollowFeedParams> {
  FeedRepository feedRepository;
  AddFollowFeed(this.feedRepository);

  @override
  Future<Either<Failure, int>> call(AddFollowFeedParams params) async {
    return await feedRepository.addAndFollowFeed(
      params.feedUrl,
      params.feedType,
    );
  }
}
