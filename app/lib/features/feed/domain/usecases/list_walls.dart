import 'package:app/core/errors/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListWalls implements Usecase<List<Wall>, NoParams> {
  FeedRepository feedRepository;
  ListWalls(this.feedRepository);

  @override
  Future<Either<Failure, List<Wall>>> call(NoParams params) async {
    return await feedRepository.listWalls();
  }
}
