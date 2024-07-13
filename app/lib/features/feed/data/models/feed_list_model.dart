import 'dart:convert';

import 'package:app/core/common/models/pagination_metadata_model.dart';
import 'package:app/features/feed/data/models/feed_model.dart';
import 'package:app/features/feed/domain/entities/feed_list.dart';

class FeedListModel extends FeedList {
  const FeedListModel({
    required List<FeedModel> feeds,
    required PaginationMetadataModel metadata,
  }) : super(
          feeds: feeds,
          metadata: metadata,
        );

  FeedListModel copyWith({
    List<FeedModel>? feeds,
    PaginationMetadataModel? metadata,
  }) {
    return FeedListModel(
      feeds: feeds ?? this.feeds.cast<FeedModel>(),
      metadata: metadata ?? this.metadata as PaginationMetadataModel,
    );
  }

  factory FeedListModel.fromMap(Map<String, dynamic> map) {
    return FeedListModel(
      feeds: (map['feeds'] as List)
          .map((feed) => FeedModel.fromMap(feed))
          .toList(),
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory FeedListModel.fromJson(String source) =>
      FeedListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
