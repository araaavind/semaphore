import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

class ChooseUsernamePage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ChooseUsernamePage());
  const ChooseUsernamePage({super.key});

  @override
  State<ChooseUsernamePage> createState() => _ChooseUsernamePageState();
}

class _ChooseUsernamePageState extends State<ChooseUsernamePage> {
  final usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isUsernameTaken = false;

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FormState? formState = formKey.currentState;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUsernameFailure) {
              setState(() {
                _isUsernameTaken = true;
                formState!.validate();
              });
            } else if (state is AuthUsernameSuccess) {
              setState(() {
                _isUsernameTaken = false;
                formState!.validate();
              });
            } else if (state is AuthFailure) {
              showSnackbar(context, state.message);
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleTextSpan(),
                  const SizedBox(height: 20),
                  AuthField(
                    hintText: 'Username',
                    controller: usernameController,
                    errorMaxLines: 2,
                    onChanged: (value) {
                      setState(() {
                        _isUsernameTaken = false;
                      });
                      if (formState!.validate()) {
                        context.read<AuthBloc>().add(
                              AuthCheckUsernameEvent(
                                usernameController.text.trim(),
                              ),
                            );
                      }
                    },
                    validator: _usernameValidator,
                    validBorderColor: state is AuthUsernameSuccess &&
                            formState != null &&
                            formState.validate()
                        ? AppPalette.green
                        : null,
                    suffixIcon: state is AuthLoading
                        ? SizedBox(
                            height: 10,
                            width: 10,
                            child: SpinKitFadingCircle(
                              color: context.theme.colorScheme.secondary
                                  .withAlpha(127),
                              size: 24.0,
                            ),
                          )
                        : (state is AuthUsernameSuccess &&
                                formState != null &&
                                formState.validate()
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
                              formState != null &&
                              formState.validate()) {
                            context.goNamed(
                              'signup',
                              pathParameters: {
                                'username': usernameController.text.trim(),
                              },
                            );
                          }
                        }),
                  ),
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
      return 'Username should not be blank';
    } else if (value.length < 8) {
      return 'Username should be atleast 8 characters long';
    } else if (value.length > 16) {
      return 'Username should be less than 16 characters long';
    } else if (!validCharsRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    } else if (value.startsWith('.') ||
        value.endsWith('.') ||
        value.startsWith('_') ||
        value.endsWith('_')) {
      return 'Username should not start or end with a dot or an underscore';
    } else if (value.contains('..') ||
        value.contains('__') ||
        value.contains('._') ||
        value.contains('_.')) {
      return 'Username should not contain consecutive dots, underscores, or their combination.';
    } else if (_isUsernameTaken) {
      return 'Username is already taken';
    }
    return null;
  }
}

class TitleTextSpan extends StatelessWidget {
  const TitleTextSpan({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'pick a ',
        style: context.theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w100,
          color: context.theme.colorScheme.secondary,
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
              color: context.theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
