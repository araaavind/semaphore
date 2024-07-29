import 'package:app/core/constants/server_constants.dart';
import 'package:app/core/utils/stream_tranformers.dart';
import 'package:app/features/feed/domain/entities/followers_list.dart';
import 'package:app/features/feed/domain/usecases/list_followers_of_feed.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'list_followers_event.dart';
part 'list_followers_state.dart';

class ListFollowersBloc extends Bloc<ListFollowersEvent, ListFollowersState> {
  final ListFollowersOfFeed _listFollowers;

  ListFollowersBloc({
    required ListFollowersOfFeed listFollowers,
  })  : _listFollowers = listFollowers,
        super(const ListFollowersState()) {
    on<ListFollowersRequested>(
      _onListFollowers,
      transformer: throttleDroppable(ServerConstants.throttleDuration),
    );
  }

  void _onListFollowers(
    ListFollowersRequested event,
    Emitter<ListFollowersState> emit,
  ) async {
    emit(state.copyWith(status: ListFollowersStatus.loading));
    final followersRes = await _listFollowers(
      ListFollowersOfFeedParams(
        feedId: event.feedId,
        searchKey: event.searchKey,
        searchValue: event.searchValue,
        sortKey: event.sortKey,
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    switch (followersRes) {
      case Left(value: final l):
        emit(state.copyWith(
          status: ListFollowersStatus.failure,
          message: l.message,
        ));
      case Right(value: final followerList):
        emit(state.copyWith(
          status: ListFollowersStatus.success,
          followersList: followerList,
        ));
    }
  }
}
