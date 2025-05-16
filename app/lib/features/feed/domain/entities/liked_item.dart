import 'package:app/features/feed/domain/entities/item.dart';
import 'package:equatable/equatable.dart';

class LikedItem extends Equatable {
  final int userId;
  final int itemId;
  final DateTime likedAt;
  final Item item;

  const LikedItem({
    required this.userId,
    required this.itemId,
    required this.likedAt,
    required this.item,
  });

  @override
  List<Object?> get props => [
        userId,
        itemId,
        likedAt,
        item,
      ];
}
