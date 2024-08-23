import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String? name;
  final String? email;

  const Author({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}

class Enclosure extends Equatable {
  final String? url;
  final int? length;
  final String? type;

  const Enclosure({
    required this.url,
    required this.length,
    required this.type,
  });

  @override
  List<Object?> get props => [url, length, type];
}

class Item extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String link;
  final DateTime? pubDate;
  final DateTime? pubUpdated;
  final String guid;
  final String? imageUrl;
  final Feed? feed;
  final String? content;
  final List<String>? categories;
  final List<Author>? authors;
  final List<Enclosure>? enclosures;

  const Item({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    this.pubDate,
    this.pubUpdated,
    required this.guid,
    this.imageUrl,
    this.feed,
    this.content,
    this.categories,
    this.authors,
    this.enclosures,
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
        feed,
        content,
        categories,
        authors,
        enclosures,
      ];
}
