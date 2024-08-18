import 'package:app/core/common/entities/paginated_list.dart';
import 'package:app/features/wall/domain/entities/item.dart';

class ItemList extends PaginatedList {
  final List<Item> items;
  const ItemList({
    this.items = const <Item>[],
    super.metadata,
  });

  @override
  List<Object> get props => super.props..addAll([items]);
}
