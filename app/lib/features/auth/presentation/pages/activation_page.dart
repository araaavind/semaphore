import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivationPage extends StatefulWidget {
  final bool isOnboarding;
  const ActivationPage({
    super.key,
    this.isOnboarding = false,
  });

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final token = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              if (widget.isOnboarding) {
                context.goNamed(RouteConstants.wallPageName);
              } else {
                context.pop(false);
              }
            },
            child: const Text('Skip'),
          ),
        ],
      ),
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
                  hintText: 'Token',
                  controller: token,
                  errorMaxLines: 2,
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Button(
                    text: 'Activate',
                    fixedSize: const Size(140, 50),
                    onPressed: () {
                      if (widget.isOnboarding) {
                        context.goNamed(RouteConstants.wallPageName);
                      } else {
                        context.pop(false);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Did not receive token? ',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend',
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight) *
                          0.7,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TitleTextSpan extends StatelessWidget {
  const _TitleTextSpan();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text:
            'we\'ve sent an email containing the token to activate your account',
        style: context.theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
