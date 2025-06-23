import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/list_followers/list_followers_bloc.dart';
import 'package:app/features/feed/presentation/widgets/followers_list_dialog.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowersCount extends StatelessWidget {
  const FollowersCount({
    super.key,
    required this.feed,
  });

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    context.read<ListFollowersBloc>().add(
          ListFollowersRequested(feedId: feed.id),
        );
    return GestureDetector(
      onTap: () {
        final user =
            (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

        if (!(user.isAdmin ?? false)) {
          return;
        }

        showDialog(
          context: context,
          builder: (BuildContext context) => BlocProvider(
            create: (context) => serviceLocator<ListFollowersBloc>(),
            child: FollowersListDialog(
              feedId: feed.id,
            ),
          ),
        );
      },
      child: BlocBuilder<ListFollowersBloc, ListFollowersState>(
        builder: (context, state) {
          if (state.status == ListFollowersStatus.success ||
              state.status == ListFollowersStatus.initial ||
              state.status == ListFollowersStatus.loading) {
            final count = state.status == ListFollowersStatus.success
                ? state.followersList.metadata.totalRecords
                : feed.followersCount ?? 0;
            return Text(
              '${count > 0 ? '$count ' : ''}followers',
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.primary,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
