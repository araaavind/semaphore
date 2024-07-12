import 'package:app/core/common/entities/paginated_list.dart';

import 'feed.dart';

class FeedList extends PaginatedList {
  final List<Feed> feeds;
  FeedList({
    required this.feeds,
    required super.metadata,
  });
}
