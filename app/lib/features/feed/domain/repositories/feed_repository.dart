import 'package:app/core/errors/failures.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FeedRepository {
  Future<Either<Failure, FeedList>> listAllFeeds({
    String? searchKey,
    String? searchValue,
    int page,
    int pageSize,
    String? sortKey,
  });
}
