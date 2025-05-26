import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  final int id;
  final String code;
  final String name;
  final bool featured;
  final String? imageUrl;
  final String? color;
  final List<Topic>? subTopics;

  const Topic({
    required this.id,
    required this.code,
    required this.name,
    required this.featured,
    this.imageUrl,
    this.color,
    this.subTopics,
  });

  @override
  List<Object?> get props =>
      [id, code, name, featured, imageUrl, color, subTopics];
}
