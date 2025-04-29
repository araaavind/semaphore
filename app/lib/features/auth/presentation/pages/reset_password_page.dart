import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/core/utils/validate_fields.dart';
import 'package:app/features/auth/presentation/cubit/reset_password/reset_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatefulWidget {
  final bool isOnboarding;
  const ResetPasswordPage({
    super.key,
    this.isOnboarding = false,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final token = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, String>? fieldErrors;

  void updateFieldErrors([Map<String, String>? fe]) {
    setState(() {
      fieldErrors = fe;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    token.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
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
                  onChanged: (_) => updateFieldErrors(),
                  validator: (_) => validateFields(
                    jsonKey: 'token',
                    fieldErrors: fieldErrors,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  hintText: 'New password',
                  controller: password,
                  onChanged: (_) => updateFieldErrors(),
                  isPassword: true,
                  validator: (_) => validateFields(
                    jsonKey: 'password',
                    fieldErrors: fieldErrors,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  errorMaxLines: 2,
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                    listener: (context, state) {
                      if (state is ResetPasswordFailure) {
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
                      if (state is ResetPasswordSuccess) {
                        showSnackbar(
                          context,
                          TextConstants.passwordResetSuccessMessage,
                          type: SnackbarType.info,
                        );
                        context.goNamed(RouteConstants.loginPageName);
                      }
                      if (state is SendPasswordResetTokenSuccess) {
                        showSnackbar(
                          context,
                          state.message,
                          type: SnackbarType.info,
                        );
                      }
                    },
                    builder: (context, state) {
                      return Button(
                        text: 'Reset password',
                        fixedSize: const Size(180, 50),
                        onPressed: () {
                          context.read<ResetPasswordCubit>().resetPassword(
                              token.text.trim(), password.text.trim());
                        },
                        isLoading: state is ResetPasswordLoading,
                      );
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
}

class _TitleTextSpan extends StatelessWidget {
  const _TitleTextSpan();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Enter the token provided in your email',
        style: context.theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
