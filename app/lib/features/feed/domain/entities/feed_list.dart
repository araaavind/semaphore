import 'package:app/core/common/entities/paginated_list.dart';

import 'feed.dart';

class FeedList extends PaginatedList {
  final List<Feed> feeds;
  const FeedList({
    required this.feeds,
    required super.metadata,
  });

  @override
  List<Object> get props => super.props..addAll([feeds]);
}
