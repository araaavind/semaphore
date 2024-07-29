import 'package:app/core/common/widgets/button.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FeedViewPage extends StatefulWidget {
  final Feed feed;
  final FollowFeedBloc followFeedBlocValue;
  final bool isFollowed;
  const FeedViewPage({
    super.key,
    required this.feed,
    required this.followFeedBlocValue,
    required this.isFollowed,
  });

  @override
  State<FeedViewPage> createState() => _FeedViewPageState();
}

class _FeedViewPageState extends State<FeedViewPage> {
  bool isFollowed = false;
  late final Feed feed;

  @override
  void initState() {
    super.initState();
    feed = widget.feed;
    isFollowed = widget.isFollowed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.followFeedBlocValue,
      child: Scaffold(
        appBar: AppBar(),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    widget.feed.title,
                    style: context.theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 5,
                    minFontSize: context.theme.textTheme.titleLarge!.fontSize!,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    widget.feed.description ?? '',
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  BlocConsumer<FollowFeedBloc, FollowFeedState>(
                    listener: (context, state) {
                      if (state.status == FollowFeedStatus.failure) {
                        showSnackbar(context, state.message!);
                      }
                      if (state.feedId == widget.feed.id &&
                          (state.status == FollowFeedStatus.followed ||
                              state.status == FollowFeedStatus.unfollowed)) {
                        setState(() {
                          isFollowed = !isFollowed;
                        });
                      }
                    },
                    builder: (context, state) {
                      var buttonText = 'Follow';
                      var action = FollowUnfollowAction.follow;
                      if (isFollowed) {
                        buttonText = 'Unfollow';
                        action = FollowUnfollowAction.unfollow;
                      }
                      return Button(
                        text: buttonText,
                        fixedSize: const Size.fromHeight(40.0),
                        filled: !isFollowed,
                        onPressed: () {
                          context.read<FollowFeedBloc>().add(
                                FollowUnfollowRequested(
                                  feed.id,
                                  action: action,
                                ),
                              );
                        },
                        isLoading: state.feedId == feed.id &&
                            state.status == FollowFeedStatus.loading,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  if (feed.pubUpdated != null)
                    Text(
                      'Last published at ${DateFormat('d MMM, yyyy').format(feed.pubUpdated!)}',
                      style: context.theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
