import 'package:app/core/common/entities/paginated_list.dart';
import 'package:app/core/common/entities/user.dart';

class FollowersList extends PaginatedList {
  final List<User> users;
  const FollowersList({
    this.users = const <User>[],
    super.metadata,
  });

  @override
  List<Object> get props => super.props..addAll([users]);
}
