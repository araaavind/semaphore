import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

class ChooseUsernamePage extends StatefulWidget {
  const ChooseUsernamePage({super.key});

  @override
  State<ChooseUsernamePage> createState() => _ChooseUsernamePageState();
}

class _ChooseUsernamePageState extends State<ChooseUsernamePage> {
  final usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isUsernameTaken = false;
  final Debouncer _debouncer = Debouncer(
    duration: ServerConstants.debounceDuration,
  );

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUsernameFailure) {
              if (state.fieldErrors != null) {
                setState(() {
                  _isUsernameTaken = true;
                });
                formKey.currentState!.validate();
              } else {
                showSnackbar(
                  context,
                  state.message,
                  type: SnackbarType.failure,
                );
              }
            } else if (state is AuthUsernameSuccess) {
              setState(() {
                _isUsernameTaken = false;
              });
              formKey.currentState!.validate();
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TitleTextSpan(),
                  const SizedBox(height: 20),
                  AppTextField(
                    hintText: 'Username',
                    controller: usernameController,
                    errorMaxLines: 2,
                    onChanged: (value) {
                      _debouncer.run(
                        () {
                          setState(() {
                            _isUsernameTaken = false;
                          });
                          if (formKey.currentState != null &&
                              formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthCheckUsernameRequested(
                                    usernameController.text.trim(),
                                  ),
                                );
                          }
                        },
                      );
                    },
                    validator: _usernameValidator,
                    validBorderColor: state is AuthUsernameSuccess &&
                            formKey.currentState != null &&
                            formKey.currentState!.validate()
                        ? AppPalette.green
                        : null,
                    suffixIcon: state is AuthLoading
                        ? SizedBox(
                            height: 10,
                            width: 10,
                            child: SpinKitRing(
                              color: context.theme.colorScheme.primary
                                  .withAlpha(127),
                              lineWidth: 2.5,
                              size: 22.0,
                            ),
                          )
                        : (state is AuthUsernameSuccess &&
                                formKey.currentState != null &&
                                formKey.currentState!.validate()
                            ? const Icon(
                                Icons.check,
                                color: AppPalette.green,
                              )
                            : null),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Button(
                        text: 'Continue',
                        fixedSize: const Size(120, 50),
                        onPressed: () {
                          if (state is AuthUsernameSuccess &&
                              formKey.currentState != null &&
                              formKey.currentState!.validate()) {
                            context.goNamed(
                              RouteConstants.signupPageName,
                              pathParameters: {
                                'username': usernameController.text.trim(),
                              },
                            );
                          }
                        }),
                  ),
                  SizedBox(
                    height:
                        Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _usernameValidator(value) {
    final RegExp validCharsRegex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (value!.isEmpty) {
      return TextConstants.usernameBlankErrorMessage;
    } else if (value.length < 8) {
      return TextConstants.usernameMinCharsErrorMessage;
    } else if (value.length > 16) {
      return TextConstants.usernameMaxCharsErrorMessage;
    } else if (!validCharsRegex.hasMatch(value)) {
      return TextConstants.usernameInvalidCharsErrorMessage;
    } else if (value.startsWith('.') ||
        value.endsWith('.') ||
        value.startsWith('_') ||
        value.endsWith('_')) {
      return TextConstants.usernameInvalidPrefixSuffixErrorMessage;
    } else if (value.contains('..') ||
        value.contains('__') ||
        value.contains('._') ||
        value.contains('_.')) {
      return TextConstants.usernameInvalidContentsErrorMessage;
    } else if (_isUsernameTaken) {
      return TextConstants.usernameTakenErrorMessage;
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
        text: 'pick a ',
        style: context.theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w100,
        ),
        children: [
          TextSpan(
            text: 'cool ',
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'username',
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}
