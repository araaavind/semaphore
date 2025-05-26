import 'dart:convert';

import 'package:app/features/feed/domain/entities/topic.dart';

class TopicModel extends Topic {
  const TopicModel({
    required super.id,
    required super.code,
    required super.name,
    required super.featured,
    super.imageUrl,
    super.color,
    super.subTopics,
  });

  TopicModel copyWith({
    int? id,
    String? code,
    String? name,
    bool? featured,
    String? imageUrl,
    String? color,
    List<Topic>? subTopics,
  }) {
    return TopicModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      featured: featured ?? this.featured,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      subTopics: subTopics ?? this.subTopics,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'featured': featured,
      'image_url': imageUrl,
      'color': color,
      'sub_topics': subTopics?.map((f) => (f as TopicModel).toMap()).toList(),
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      featured: map['featured'] != null ? map['featured'] as bool : false,
      imageUrl: map['image_url'] as String?,
      color: map['color'] as String?,
      subTopics: map['sub_topics'] != null
          ? (map['sub_topics'] as List)
              .map((topic) => TopicModel.fromMap(topic))
              .toList()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TopicModel.fromJson(String source) =>
      TopicModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
