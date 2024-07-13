import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/choose_username_page.dart';
import 'package:app/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  static route({bool isOnboarding = false}) => MaterialPageRoute(
        builder: (context) => LoginPage(isOnboarding: isOnboarding),
      );
  final bool isOnboarding;

  const LoginPage({super.key, this.isOnboarding = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameOrEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackbar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }
            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleTextSpan(widget: widget),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      AuthField(
                        hintText: 'Username or Email',
                        controller: usernameOrEmailController,
                      ),
                      const SizedBox(height: 10),
                      AuthField(
                        hintText: 'Password',
                        controller: passwordController,
                        isPassword: true,
                        autovalidateMode: AutovalidateMode.disabled,
                      ),
                      const SizedBox(height: 20),
                      Button(
                        text: 'Log in',
                        fixedSize: const Size(160, 50),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthLoginEvent(
                                    usernameOrEmail:
                                        usernameOrEmailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            ChooseUsernamePage.route(),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: context.theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Create one',
                                style: context.theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TitleTextSpan extends StatelessWidget {
  const TitleTextSpan({
    super.key,
    required this.widget,
  });

  final LoginPage widget;

  @override
  Widget build(BuildContext context) {
    return !widget.isOnboarding
        ? RichText(
            text: TextSpan(
              text: 'dive in to ',
              style: context.theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w100,
                color: context.theme.colorScheme.secondary,
              ),
              children: [
                TextSpan(
                  text: 'Semaphore',
                  style: context.theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UIConstants.onboardingLoginPageMessage1,
                style: context.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w100,
                  color: context.theme.colorScheme.secondary,
                ),
              ),
              Text(
                UIConstants.onboardingLoginPageMessage2,
                style: context.theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
  }
}
