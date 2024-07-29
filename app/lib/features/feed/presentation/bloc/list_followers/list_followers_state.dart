part of 'list_followers_bloc.dart';

enum ListFollowersStatus { initial, loading, success, failure }

@immutable
class ListFollowersState extends Equatable {
  final ListFollowersStatus status;
  final FollowersList followersList;
  final String? message;

  const ListFollowersState({
    this.status = ListFollowersStatus.initial,
    this.followersList = const FollowersList(),
    this.message,
  });

  ListFollowersState copyWith({
    ListFollowersStatus? status,
    FollowersList? followersList,
    String? message,
  }) {
    return ListFollowersState(
      status: status ?? this.status,
      followersList: followersList ?? this.followersList,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, followersList, message];
}
