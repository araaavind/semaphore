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
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FeedInputType selectedFeedType = FeedInputType.url;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _onFeedTypeChanged(FeedInputType? type) {
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
                        ),
                        const SizedBox(height: 40),
                        _buildTitleText(context),
                        const SizedBox(height: 20),
                        AppTextField(
                          hintText: selectedFeedType.hintText,
                          controller: textController,
                          errorMaxLines: 2,
                          validator: selectedFeedType.validator,
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
                                    final String formattedURL = selectedFeedType
                                        .converter(textController.text.trim());

                                    if (context.mounted) {
                                      context.read<AddFollowFeedBloc>().add(
                                            AddFollowRequested(formattedURL),
                                          );
                                    }
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

  RichText _buildTitleText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'add a new',
        style: context.theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w100,
        ),
        children: [
          TextSpan(
            text: selectedFeedType == FeedInputType.url
                ? ''
                : ' ${selectedFeedType.displayName}',
            style: context.theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: selectedFeedType.selectedColor(context),
            ),
          ),
          TextSpan(
            text: ' feed',
            style: context.theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedTypeSelector extends StatelessWidget {
  final FeedInputType selectedType;
  final ValueChanged<FeedInputType?> onTypeChanged;

  const _FeedTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: FeedInputType.values.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!isSelected)
                Padding(
                  padding: EdgeInsets.only(right: type.iconPadding),
                  child: Icon(
                    type.icon,
                    size: type.iconSize,
                    color: isSelected
                        ? type.selectedLabelColor(context)
                        : type.labelColor(context),
                  ),
                ),
              Text(type.displayName),
            ],
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          selected: isSelected,
          selectedColor: type.selectedColor(context).withOpacity(0.2),
          onSelected: (selected) {
            if (selected) {
              onTypeChanged(type);
            }
          },
          side: BorderSide(
            color: isSelected
                ? type.selectedColor(context).withOpacity(0.6)
                : context.theme.colorScheme.outline,
          ),
          labelStyle: TextStyle(
            color: isSelected
                ? type.selectedLabelColor(context)
                : type.labelColor(context),
          ),
          checkmarkColor: isSelected
              ? type.selectedLabelColor(context)
              : type.labelColor(context),
        );
      }).toList(),
    );
  }
}
