import 'package:equatable/equatable.dart';

class Wall extends Equatable {
  final int id;
  final String name;
  final bool isPrimary;
  final int userId;

  const Wall({
    required this.id,
    required this.name,
    required this.isPrimary,
    required this.userId,
  });

  @override
  List<Object> get props => [id, name, isPrimary, userId];
}
