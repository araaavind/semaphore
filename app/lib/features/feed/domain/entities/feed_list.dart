import 'package:app/core/common/entities/paginated_list.dart';

import 'feed.dart';

class FeedList extends PaginatedList {
  final List<Feed> feeds;
  const FeedList({
    this.feeds = const <Feed>[],
    super.metadata,
  });

  @override
  List<Object> get props => super.props..addAll([feeds]);
}
