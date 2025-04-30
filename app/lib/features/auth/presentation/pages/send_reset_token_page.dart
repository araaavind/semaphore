import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/core/utils/validate_fields.dart';
import 'package:app/features/auth/presentation/cubit/reset_password/reset_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SendResetTokenPage extends StatefulWidget {
  const SendResetTokenPage({
    super.key,
  });

  @override
  State<SendResetTokenPage> createState() => _SendResetTokenPageState();
}

class _SendResetTokenPageState extends State<SendResetTokenPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, String>? fieldErrors;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
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
                  hintText: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {
                    fieldErrors = null;
                  }),
                  validator: (_) {
                    if (fieldErrors != null &&
                        fieldErrors!.keys.contains('email')) {
                      return validateFields(
                        jsonKey: 'email',
                        fieldErrors: fieldErrors,
                      );
                    }
                    return validateFields(
                      jsonKey: 'email',
                      fieldErrors: fieldErrors,
                    );
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      if (state is SendPasswordResetTokenSuccess) {
                        showSnackbar(
                          context,
                          state.message,
                          type: SnackbarType.info,
                        );
                        context.pushNamed(RouteConstants.resetPasswordPageName);
                      }
                    },
                    builder: (context, state) {
                      return Button(
                        text: 'Send Reset Token',
                        width: 240,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<ResetPasswordCubit>()
                                .sendPasswordResetToken(
                                    emailController.text.trim());
                          }
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
        text: 'Enter your email to receive a password reset token',
        style: context.theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
