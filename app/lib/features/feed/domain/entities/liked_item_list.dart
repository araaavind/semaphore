import 'package:app/core/common/entities/paginated_list.dart';
import 'package:app/features/feed/domain/entities/liked_item.dart';

class LikedItemList extends OffsetBasedList {
  final List<LikedItem> likedItems;
  const LikedItemList({
    this.likedItems = const <LikedItem>[],
    super.metadata,
  });

  @override
  List<Object> get props => super.props..addAll([likedItems]);
}
