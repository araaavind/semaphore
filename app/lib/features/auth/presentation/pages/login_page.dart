import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
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
                type: SnackbarType.success,
              );
            case NetworkStatus.disconnected:
              showSnackbar(
                context,
                TextConstants.networkDisconnectedMessage,
                type: SnackbarType.failure,
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
                showSnackbar(
                  context,
                  state.message,
                  type: SnackbarType.failure,
                );
              }
            }
            if (state is AuthSuccess && state.isNewUser) {
              context.pushReplacementNamed(RouteConstants.usernamePageName,
                  extra: {'isOAuthUser': true});
            }
          },
          builder: (context, state) {
            if (state is AuthLoading || state is AuthSuccess) {
              return const Loader();
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.pagePadding),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TitleTextSpan(isOnboarding: widget.isOnboarding),
                          const SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppTextField(
                                hintText: 'Username or Email',
                                controller: usernameOrEmailController,
                                keyboardType: TextInputType.emailAddress,
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 10),
                              AppTextField(
                                hintText: 'Password',
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                isPassword: true,
                                onChanged: (_) => setState(() {
                                  fieldErrors = null;
                                }),
                                validator: (_) => validateFields(
                                  jsonKey: 'password',
                                  fieldErrors: fieldErrors,
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.sendResetTokenPageName,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Align(
                                    heightFactor: 2,
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Forgot password? ',
                                        style: context
                                            .theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color:
                                              context.theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Button(
                                text: 'Log in',
                                width: 160,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          AuthLoginRequested(
                                            usernameOrEmail:
                                                usernameOrEmailController.text
                                                    .trim(),
                                            password:
                                                passwordController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                              ),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: () {
                                  context
                                      .goNamed(RouteConstants.usernamePageName);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Don\'t have an account? ',
                                    style: context.theme.textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Create one',
                                        style: context
                                            .theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              context.theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 35),
                              _buildOrDivider(context),
                              const SizedBox(height: 35),
                              _buildGoogleSignInButton(context),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
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

  String? validateFields({
    required String jsonKey,
    Map<String, String>? fieldErrors,
  }) {
    if (fieldErrors != null && fieldErrors.containsKey(jsonKey)) {
      return fieldErrors[jsonKey];
    }
    return null;
  }

  Widget _buildOrDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: context.theme.colorScheme.outline.withAlpha(204),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: context.theme.colorScheme.outline.withAlpha(204),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AuthBloc>().add(AuthGoogleLoginRequested());
      },
      child: Container(
        width: 240,
        height: 54,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.onSurface.withAlpha(40),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1.5,
            color: context.theme.colorScheme.outline.withAlpha(127),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MingCute.google_fill,
              color: context.theme.colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: context.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
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
                  color: context.theme.colorScheme.primary,
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
