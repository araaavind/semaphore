import 'package:app/core/common/models/user_model.dart';
import 'package:app/features/auth/domain/entities/oauth_response.dart';
import 'dart:convert';

class OAuthResponseModel extends OAuthResponse {
  const OAuthResponseModel({
    required UserModel super.user,
    required super.isNewUser,
  });

  OAuthResponseModel copyWith({
    UserModel? user,
    bool? isNewUser,
  }) {
    return OAuthResponseModel(
      user: user ?? this.user as UserModel,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  factory OAuthResponseModel.fromMap(Map<String, dynamic> map) {
    return OAuthResponseModel(
      user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
      isNewUser: map['is_new_user'] as bool,
    );
  }

  factory OAuthResponseModel.fromJson(String source) =>
      OAuthResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
