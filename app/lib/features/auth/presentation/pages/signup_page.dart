import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  final String username;

  const SignupPage({super.key, required this.username});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, String>? fieldErrors;

  void updateFieldErrors([Map<String, String>? fe]) {
    setState(() {
      fieldErrors = fe;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: 'join ',
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
              ),
              const SizedBox(height: 20),
              AppTextField(
                hintText: 'Full name',
                controller: nameController,
                keyboardType: TextInputType.name,
                onChanged: (_) => updateFieldErrors(),
                validator: (_) => validateFields(
                  jsonKey: 'full_name',
                  fieldErrors: fieldErrors,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 10),
              AppTextField(
                hintText: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => updateFieldErrors(),
                validator: (_) => validateFields(
                  jsonKey: 'email',
                  fieldErrors: fieldErrors,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 10),
              AppTextField(
                hintText: 'Password',
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (_) => updateFieldErrors(),
                isPassword: true,
                validator: (_) => validateFields(
                  jsonKey: 'password',
                  fieldErrors: fieldErrors,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                errorMaxLines: 2,
              ),
              const SizedBox(height: 20),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSignupFailure) {
                    if (state.fieldErrors != null) {
                      updateFieldErrors(state.fieldErrors);
                      formKey.currentState!.validate();
                    } else {
                      showSnackbar(
                        context,
                        state.message,
                        type: SnackbarType.failure,
                      );
                    }
                  } else if (state is AuthSignupSuccess) {
                    context.goNamed(
                      RouteConstants.loginPageName,
                      queryParameters: {'isOnboarding': 'true'},
                    );
                  }
                },
                builder: (context, state) {
                  return Button(
                    text: 'Sign up',
                    width: 160,
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              AuthSignupRequested(
                                fullName: nameController.text.trim(),
                                email: emailController.text.trim(),
                                username: widget.username,
                                password: passwordController.text.trim(),
                              ),
                            );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  context.goNamed(RouteConstants.loginPageName);
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: context.theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Log in',
                        style: context.theme.textTheme.bodyMedium?.copyWith(
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
        ),
      ),
    );
  }
}
