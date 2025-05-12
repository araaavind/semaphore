import 'package:app/core/common/entities/user.dart';
import 'package:equatable/equatable.dart';

class OAuthResponse extends Equatable {
  final User user;
  final bool isNewUser;

  const OAuthResponse({
    required this.user,
    required this.isNewUser,
  });

  @override
  List<Object?> get props => [user, isNewUser];
}
