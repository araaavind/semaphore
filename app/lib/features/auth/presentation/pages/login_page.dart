import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/extensions/app_snackbar_color_theme.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/validate_fields.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  final bool isOnboarding;

  const LoginPage({super.key, this.isOnboarding = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, String>? fieldErrors;

  @override
  void dispose() {
    usernameOrEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<NetworkCubit, NetworkState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case NetworkStatus.connected:
              showSnackbar(
                context,
                TextConstants.networkConnectedMessage,
                backgroundColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOnlineContainer,
                textColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOnlineOnContainer,
              );
            case NetworkStatus.disconnected:
              showSnackbar(
                context,
                TextConstants.networkDisconnectedMessage,
                backgroundColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOfflineContainer,
                textColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOfflineOnContainer,
              );
          }
        },
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoginFailure) {
              if (state.fieldErrors != null) {
                setState(() {
                  fieldErrors = state.fieldErrors;
                });
                if (formKey.currentState != null) {
                  formKey.currentState!.validate();
                }
              } else {
                showSnackbar(context, state.message);
              }
            }
          },
          builder: (context, state) {
            if (state is AuthLoading || state is AuthSuccess) {
              return const Loader();
            }
            return Padding(
              padding: const EdgeInsets.all(UIConstants.pagePadding),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TitleTextSpan(isOnboarding: widget.isOnboarding),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        AppTextField(
                          hintText: 'Username or Email',
                          controller: usernameOrEmailController,
                          onChanged: (_) => setState(() {
                            fieldErrors = null;
                          }),
                          validator: (_) {
                            if (fieldErrors != null &&
                                fieldErrors!.keys.contains('username')) {
                              return validateFields(
                                jsonKey: 'username',
                                fieldErrors: fieldErrors,
                              );
                            } else if (fieldErrors != null &&
                                fieldErrors!.keys.contains('email')) {
                              return validateFields(
                                jsonKey: 'email',
                                fieldErrors: fieldErrors,
                              );
                            }
                            return validateFields(
                              jsonKey: 'username_or_email',
                              fieldErrors: fieldErrors,
                            );
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          hintText: 'Password',
                          controller: passwordController,
                          isPassword: true,
                          onChanged: (_) => setState(() {
                            fieldErrors = null;
                          }),
                          validator: (_) => validateFields(
                            jsonKey: 'password',
                            fieldErrors: fieldErrors,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 20),
                        Button(
                          text: 'Log in',
                          fixedSize: UIConstants.defaultButtonFixedSize,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    AuthLoginRequested(
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
                            context.goNamed(RouteConstants.usernamePageName);
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
                                    color: context.theme.colorScheme.primary,
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
    this.isOnboarding = false,
  });

  final bool isOnboarding;

  @override
  Widget build(BuildContext context) {
    return !isOnboarding
        ? RichText(
            text: TextSpan(
              text: 'dive in to ',
              style: context.theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w100,
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
                TextConstants.onboardingLoginPageMessage1,
                style: context.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w100,
                  color: context.theme.colorScheme.secondary,
                ),
              ),
              Text(
                TextConstants.onboardingLoginPageMessage2,
                style: context.theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
  }
}
