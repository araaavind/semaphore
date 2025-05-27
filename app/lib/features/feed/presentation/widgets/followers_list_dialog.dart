import 'package:app/core/common/entities/user.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/presentation/bloc/list_followers/list_followers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FollowersListDialog extends StatefulWidget {
  final int feedId;
  const FollowersListDialog({
    super.key,
    required this.feedId,
  });

  @override
  State<FollowersListDialog> createState() => _FollowersListDialogState();
}

class _FollowersListDialogState extends State<FollowersListDialog> {
  final PagingController<int, User> _pagingController = PagingController(
    firstPageKey: 1,
    // invisibleItemsThreshold will determine how many items should be loaded
    // after the first page is loaded (if the first page does not fill the
    // screen, items enough to fill the page will be loaded anyway unless
    // invisibleItemsThreshold is set to 0).
    invisibleItemsThreshold: 1,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) {
        context.read<ListFollowersBloc>().add(
              ListFollowersRequested(
                feedId: widget.feedId,
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
              ),
            );
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        'Followers',
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
      titlePadding: const EdgeInsets.all(UIConstants.pagePadding),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
      children: [
        BlocListener<ListFollowersBloc, ListFollowersState>(
          listener: (context, state) {
            if (state.status != ListFollowersStatus.loading) {
              // _refreshController.refreshCompleted();
            }
            if (state.status == ListFollowersStatus.success) {
              if (state.followersList.metadata.currentPage ==
                  state.followersList.metadata.lastPage) {
                _pagingController.appendLastPage(state.followersList.users);
              } else {
                final nextPage = state.followersList.metadata.currentPage + 1;
                _pagingController.appendPage(
                  state.followersList.users,
                  nextPage,
                );
              }
            } else if (state.status == ListFollowersStatus.failure) {
              _pagingController.error = state.message;
            }
          },
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.theme.colorScheme.outline,
                  width: UIConstants.borderWidth,
                ),
              ),
            ),
            child: PagedListView<int, User>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<User>(
                itemBuilder: (context, item, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.comfortable,
                  dense: true,
                  title: Text(
                    item.fullName ?? 'User',
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.username,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                  title: TextConstants.feedFollowersFetchErrorTitle,
                  message: _pagingController.error,
                  onTryAgain: () {
                    _pagingController.refresh();
                  },
                ),
                newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                  title: TextConstants.feedFollowersFetchErrorTitle,
                  message: _pagingController.error,
                  onTap: _pagingController.retryLastFailedRequest,
                ),
                firstPageProgressIndicatorBuilder: (context) => const Stack(
                  children: [
                    Positioned(
                      top: -50,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Loader(),
                    )
                  ],
                ),
                newPageProgressIndicatorBuilder: (context) =>
                    const ShimmerLoader(pageSize: 2),
                noItemsFoundIndicatorBuilder: (_) => const NoMoreItemsIndicator(
                  title: TextConstants.feedFollowersEmptyMessageTitle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
