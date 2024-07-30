import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(),
      body: Builder(builder: (context) {
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
                  child: Button(
                    text: 'Add feed',
                    fixedSize: const Size(120, 50),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // add and follow feed
                      }
                    },
                  ),
                ),
                SizedBox(
                  height:
                      Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight,
                )
              ],
            ),
          ),
        );
      }),
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
