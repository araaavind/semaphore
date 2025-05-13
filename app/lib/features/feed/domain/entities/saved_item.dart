import 'package:app/features/feed/domain/entities/item.dart';
import 'package:equatable/equatable.dart';

class SavedItem extends Equatable {
  final int userId;
  final int itemId;
  final DateTime savedAt;
  final Item item;

  const SavedItem({
    required this.userId,
    required this.itemId,
    required this.savedAt,
    required this.item,
  });

  @override
  List<Object?> get props => [
        userId,
        itemId,
        savedAt,
        item,
      ];
}
