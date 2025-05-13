import 'dart:convert';

import 'package:app/features/feed/data/models/feed_model.dart';
import 'package:app/features/feed/domain/entities/item.dart';

class AuthorModel extends Author {
  const AuthorModel({
    super.name,
    super.email,
  });

  @override
  List<Object?> get props => [name, email];

  AuthorModel copyWith({
    String? name,
    String? email,
  }) {
    return AuthorModel(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
    };
  }

  factory AuthorModel.fromMap(Map<String, dynamic> map) {
    return AuthorModel(
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthorModel.fromJson(String source) =>
      AuthorModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class EnclosureModel extends Enclosure {
  const EnclosureModel({
    super.url,
    super.length,
    super.type,
  });

  @override
  List<Object?> get props => [url, length, type];

  EnclosureModel copyWith({
    String? url,
    int? length,
    String? type,
  }) {
    return EnclosureModel(
      url: url ?? this.url,
      length: length ?? this.length,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'length': length,
      'type': type,
    };
  }

  factory EnclosureModel.fromMap(Map<String, dynamic> map) {
    return EnclosureModel(
      url: map['url'] != null ? map['url'] as String : null,
      length: map['length'] != null ? int.parse(map['length']) : null,
      type: map['type'] != null ? map['type'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EnclosureModel.fromJson(String source) =>
      EnclosureModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.title,
    required super.link,
    required super.guid,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.pubDate,
    super.pubUpdated,
    super.imageUrl,
    super.feed,
    super.content,
    super.categories,
    super.enclosures,
    super.authors,
    super.isSaved,
  });

  @override
  Item copyWith({
    int? id,
    String? title,
    String? description,
    String? link,
    String? guid,
    DateTime? pubDate,
    DateTime? pubUpdated,
    String? imageUrl,
    covariant FeedModel? feed,
    String? content,
    List<String>? categories,
    covariant List<AuthorModel>? authors,
    List<Enclosure>? enclosures,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSaved,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      guid: guid ?? this.guid,
      pubDate: pubDate ?? this.pubDate,
      pubUpdated: pubUpdated ?? this.pubUpdated,
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'guid': guid,
      'pub_date': pubDate?.toIso8601String(),
      'pub_updated': pubUpdated?.toIso8601String(),
      'image_url': imageUrl,
      'feed': (feed as FeedModel).toMap(),
      'content': content,
      'categories': categories,
      'authors':
          authors?.map((author) => (author as AuthorModel).toMap()).toList(),
      'enclosures': enclosures
          ?.map((enclosure) => (enclosure as EnclosureModel).toMap())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_saved': isSaved,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      link: map['link'] as String,
      guid: map['guid'] as String,
      pubDate: map['pub_date'] != null
          ? DateTime.parse(map['pub_date'] as String)
          : null,
      pubUpdated: map['pub_updated'] != null
          ? DateTime.parse(map['pub_updated'] as String)
          : null,
      imageUrl: map['image_url'] != null ? map['image_url'] as String : null,
      feed: map['feed'] != null
          ? FeedModel.fromMap(map['feed'] as Map<String, dynamic>)
          : null,
      content: map['content'] != null ? map['content'] as String : null,
      categories: List<String>.from(map['categories'] ?? []),
      authors: map['authors'] != null
          ? (map['authors'] as List)
              .map((author) => AuthorModel.fromMap(author))
              .toList()
          : null,
      enclosures: map['enclosures'] != null
          ? (map['enclosures'] as List)
              .map((enclosure) => EnclosureModel.fromMap(enclosure))
              .toList()
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSaved: map['is_saved'] != null ? map['is_saved'] as bool : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
