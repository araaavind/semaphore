import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum FeedType {
  rssUrl,
  subreddit,
}

class AddFeedPage extends StatefulWidget {
  const AddFeedPage({super.key});

  @override
  State<AddFeedPage> createState() => _AddFeedPageState();
}

class _AddFeedPageState extends State<AddFeedPage> {
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FeedType selectedFeedType = FeedType.rssUrl;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _onFeedTypeChanged(FeedType? type) {
    if (type != null && type != selectedFeedType) {
      setState(() {
        selectedFeedType = type;
        textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AddFollowFeedBloc>(),
      child: Scaffold(
        appBar: AppBar(),
        body: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.pagePadding),
              child: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FeedTypeSelector(
                          selectedType: selectedFeedType,
                          onTypeChanged: _onFeedTypeChanged,
                          selectedColor: selectedFeedType == FeedType.subreddit
                              ? AppPalette.redditOrange
                              : AppPalette.rssBlue,
                        ),
                        const SizedBox(height: 40),
                        _TitleTextSpan(
                          title: selectedFeedType == FeedType.rssUrl
                              ? 'RSS'
                              : 'reddit',
                          titleColor: selectedFeedType == FeedType.rssUrl
                              ? AppPalette.rssBlue
                              : AppPalette.redditOrange,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          hintText: selectedFeedType == FeedType.rssUrl
                              ? 'Feed url'
                              : 'r/subreddit',
                          controller: textController,
                          errorMaxLines: 2,
                          validator: selectedFeedType == FeedType.rssUrl
                              ? _feedUrlValidator
                              : _subredditValidator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: BlocConsumer<AddFollowFeedBloc,
                              AddFollowFeedState>(
                            listener: (context, state) {
                              if (state.status == FollowFeedStatus.failure) {
                                if (state.fieldErrors != null &&
                                    state.fieldErrors!['feed_link'] != null) {
                                  showSnackbar(
                                    context,
                                    state.fieldErrors!['feed_link']!,
                                    type: SnackbarType.failure,
                                  );
                                } else {
                                  showSnackbar(
                                    context,
                                    state.message!,
                                    type: SnackbarType.failure,
                                  );
                                }
                              }
                              if (state.status == FollowFeedStatus.followed) {
                                context.pop({
                                  'success': true,
                                  'feedId': state.feedId,
                                });
                              }
                            },
                            builder: (context, state) {
                              return Button(
                                text: 'Add feed',
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    // Format the input based on the selected feed type
                                    final String formattedURL =
                                        selectedFeedType == FeedType.rssUrl
                                            ? textController.text.trim()
                                            : _formatSubredditToRssUrl(
                                                textController.text.trim());

                                    context.read<AddFollowFeedBloc>().add(
                                          AddFollowRequested(formattedURL),
                                        );
                                  }
                                },
                                isLoading:
                                    state.status == FollowFeedStatus.loading,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: (Scaffold.of(context).appBarMaxHeight ??
                                  kToolbarHeight) +
                              50,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatSubredditToRssUrl(String subreddit) {
    return 'https://www.reddit.com/$subreddit.rss';
  }

  String? _feedUrlValidator(String? value) {
    const urlPattern = r'^(https?:\/\/)?' // Optional protocol
        r'((([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,})' // Domain name and extension
        r'|'
        r'((\d{1,3}\.){3}\d{1,3}))' // OR IPv4
        r'(:\d+)?' // Optional port
        r'(\/[-a-zA-Z0-9%_.~+]*)*' // Path
        r'(\?[;&a-zA-Z0-9%_.~+=-]*)?' // Query string
        r'(#[-a-zA-Z0-9_]*)?$'; // Fragment locator
    final RegExp validCharsRegex = RegExp(urlPattern);
    if (value!.isEmpty) {
      return TextConstants.feedUrlBlankErrorMessage;
    } else if (!validCharsRegex.hasMatch(value)) {
      return TextConstants.feedUrlNotUrlErrorMessage;
    }
    return null;
  }

  String? _subredditValidator(value) {
    if (value!.isEmpty) {
      return 'Please enter a subreddit name';
    }

    // Basic validation for subreddit name
    const subredditPattern = r'^(r\/)?[a-zA-Z0-9_]{3,21}$';
    final RegExp validCharsRegex = RegExp(subredditPattern);

    if (!validCharsRegex.hasMatch(value)) {
      return 'Please enter a valid subreddit name (e.g., r/flutter)';
    }

    return null;
  }
}

class _FeedTypeSelector extends StatelessWidget {
  final FeedType selectedType;
  final ValueChanged<FeedType?> onTypeChanged;
  final Color? selectedColor;

  const _FeedTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        ChoiceChip(
          label: const Text('URL'),
          selected: selectedType == FeedType.rssUrl,
          selectedColor: selectedColor,
          onSelected: (selected) {
            if (selected) {
              onTypeChanged(FeedType.rssUrl);
            }
          },
        ),
        ChoiceChip(
          label: const Text('Reddit'),
          selected: selectedType == FeedType.subreddit,
          selectedColor: selectedColor,
          onSelected: (selected) {
            if (selected) {
              onTypeChanged(FeedType.subreddit);
            }
          },
        ),
      ],
    );
  }
}

class _TitleTextSpan extends StatelessWidget {
  final String title;
  final Color? titleColor;
  const _TitleTextSpan({
    required this.title,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'add a new ',
        style: context.theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w100,
        ),
        children: [
          TextSpan(
            text: title,
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor ?? context.theme.colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: ' feed',
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}
