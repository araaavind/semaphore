import 'dart:convert';

import 'package:app/core/common/models/pagination_metadata_model.dart';
import 'package:app/core/common/models/user_model.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';

class FollowersListModel extends FollowersList {
  const FollowersListModel({
    required List<UserModel> users,
    required PaginationMetadataModel metadata,
  }) : super(
          users: users,
          metadata: metadata,
        );

  FollowersListModel copyWith({
    List<UserModel>? users,
    PaginationMetadataModel? metadata,
  }) {
    return FollowersListModel(
      users: users ?? this.users.cast<UserModel>(),
      metadata: metadata ?? this.metadata as PaginationMetadataModel,
    );
  }

  factory FollowersListModel.fromMap(Map<String, dynamic> map) {
    return FollowersListModel(
      users: (map['users'] as List)
          .map((user) => UserModel.fromMap(user))
          .toList(),
      metadata: PaginationMetadataModel.fromMap(
        map['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  factory FollowersListModel.fromJson(String source) =>
      FollowersListModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
