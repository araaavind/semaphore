import 'package:app/core/common/entities/paginated_list.dart';
import 'package:app/features/feed/domain/entities/saved_item.dart';

class SavedItemList extends OffsetBasedList {
  final List<SavedItem> savedItems;
  const SavedItemList({
    this.savedItems = const <SavedItem>[],
    super.metadata,
  });

  @override
  List<Object> get props => super.props..addAll([savedItems]);
}
