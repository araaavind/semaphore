import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String? name;
  final String? email;

  const Author({required this.name, required this.email});

  Author copyWith({
    String? name,
    String? email,
  }) {
    return Author(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

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

  Enclosure copyWith({
    String? url,
    int? length,
    String? type,
  }) {
    return Enclosure(
      url: url ?? this.url,
      length: length ?? this.length,
      type: type ?? this.type,
    );
  }

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
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSaved;

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
    required this.createdAt,
    required this.updatedAt,
    this.isSaved = false,
  });

  Item copyWith({
    int? id,
    String? title,
    String? description,
    String? link,
    DateTime? pubDate,
    DateTime? pubUpdated,
    String? guid,
    String? imageUrl,
    Feed? feed,
    String? content,
    List<String>? categories,
    List<Author>? authors,
    List<Enclosure>? enclosures,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSaved,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      pubDate: pubDate ?? this.pubDate,
      pubUpdated: pubUpdated ?? this.pubUpdated,
      guid: guid ?? this.guid,
      imageUrl: imageUrl ?? this.imageUrl,
      feed: feed ?? this.feed,
      content: content ?? this.content,
      categories: categories ?? this.categories,
      authors: authors ?? this.authors,
      enclosures: enclosures ?? this.enclosures,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

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
        createdAt,
        updatedAt,
        isSaved,
      ];
}
