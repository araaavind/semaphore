// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
  });
}
