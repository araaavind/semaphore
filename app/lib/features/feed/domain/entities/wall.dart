import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:equatable/equatable.dart';

class Wall extends Equatable {
  final int id;
  final String name;
  final bool isPrimary;
  final bool isPinned;
  final int userId;
  final List<Feed>? feeds;

  const Wall({
    required this.id,
    required this.name,
    required this.isPrimary,
    required this.isPinned,
    required this.userId,
    this.feeds,
  });

  @override
  List<Object?> get props => [id, name, isPrimary, isPinned, userId, feeds];
}
