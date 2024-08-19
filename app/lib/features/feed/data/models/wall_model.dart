import 'dart:convert';

import 'package:app/features/feed/domain/entities/wall.dart';

class WallModel extends Wall {
  const WallModel({
    required super.id,
    required super.name,
    required super.isPrimary,
    required super.userId,
  });

  WallModel copyWith({
    int? id,
    String? name,
    bool? isPrimary,
    int? userId,
  }) {
    return WallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isPrimary: isPrimary ?? this.isPrimary,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'is_primary': isPrimary,
      'user_id': userId,
    };
  }

  factory WallModel.fromMap(Map<String, dynamic> map) {
    return WallModel(
      id: map['id'] as int,
      name: map['name'] as String,
      isPrimary: map['is_primary'] as bool,
      userId: map['user_id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory WallModel.fromJson(String source) =>
      WallModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
