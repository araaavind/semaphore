import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String link;
  final DateTime? pubDate;
  final DateTime? pubUpdated;
  final String guid;
  final String? imageUrl;

  const Item({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    this.pubDate,
    this.pubUpdated,
    required this.guid,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        link,
        pubDate,
        pubUpdated,
        guid,
        imageUrl,
      ];
}
