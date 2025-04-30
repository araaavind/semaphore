import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddFeedPage extends StatefulWidget {
  const AddFeedPage({super.key});

  @override
  State<AddFeedPage> createState() => _AddFeedPageState();
}

class _AddFeedPageState extends State<AddFeedPage> {
  final feedUrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    feedUrl.dispose();
    super.dispose();
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
              padding: const EdgeInsets.all(UIConstants.pagePadding),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TitleTextSpan(),
                    const SizedBox(height: 20),
                    AppTextField(
                      hintText: 'Feed url',
                      controller: feedUrl,
                      errorMaxLines: 2,
                      validator: _feedUrlValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child:
                          BlocConsumer<AddFollowFeedBloc, AddFollowFeedState>(
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
                                FocusManager.instance.primaryFocus?.unfocus();
                                context.read<AddFollowFeedBloc>().add(
                                      AddFollowRequested(
                                        feedUrl.text.trim(),
                                      ),
                                    );
                              }
                            },
                            isLoading: state.status == FollowFeedStatus.loading,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: Scaffold.of(context).appBarMaxHeight ??
                          kToolbarHeight,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _feedUrlValidator(value) {
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
}

class _TitleTextSpan extends StatelessWidget {
  const _TitleTextSpan();

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
            text: 'feed',
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
