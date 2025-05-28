import 'package:app/core/constants/constants.dart';
import 'package:app/features/feed/data/models/topic_model.dart';
import 'package:hive/hive.dart';

abstract interface class FeedLocalDatasource {
  void saveTopics(List<TopicModel> topics);
  List<TopicModel> loadTopics();
}

class FeedLocalDatasourceImpl implements FeedLocalDatasource {
  final Box box;

  FeedLocalDatasourceImpl(this.box);

  @override
  void saveTopics(List<TopicModel> topics) {
    box.put(
      ServerConstants.topicsBoxKey,
      topics.map((e) => e.toJson()).toList(),
    );
  }

  @override
  List<TopicModel> loadTopics() {
    return box
        .get(ServerConstants.topicsBoxKey, defaultValue: [])
        .map<TopicModel>((e) => TopicModel.fromJson(e))
        .toList();
  }
}
