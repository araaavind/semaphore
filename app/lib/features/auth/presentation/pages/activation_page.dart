import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/cubit/activate_user/activate_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  void initState() {
    super.initState();
    if (!widget.isOnboarding) {
      context.read<ActivateUserCubit>().sendActivationToken(
            (context.read<AppUserCubit>().state as AppUserLoggedIn).user.email,
          );
    }
  }

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
                  child: BlocConsumer<ActivateUserCubit, ActivateUserState>(
                    listener: (context, state) {
                      if (state is ActivateUserFailure) {
                        showSnackbar(
                          context,
                          state.message,
                          type: SnackbarType.failure,
                        );
                      }
                      if (state is ActivateUserSuccess) {
                        context
                            .read<AuthBloc>()
                            .add(AuthCurrentUserRequested());
                        showSnackbar(
                          context,
                          TextConstants.accountActivationSuccessMessage,
                          type: SnackbarType.info,
                        );
                        if (widget.isOnboarding) {
                          context.goNamed(RouteConstants.wallPageName);
                        } else {
                          context.pop(true);
                        }
                      }
                      if (state is SendActivationTokenSuccess) {
                        showSnackbar(
                          context,
                          state.message,
                          type: SnackbarType.info,
                        );
                      }
                    },
                    builder: (context, state) {
                      return Button(
                        text: 'Activate',
                        width: 140,
                        onPressed: () {
                          context
                              .read<ActivateUserCubit>()
                              .activateUser(token.text.trim());
                        },
                        isLoading: state is ActivateUserLoading,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: InkWell(
                    onTap: () {
                      context.read<ActivateUserCubit>().sendActivationToken(
                            (context.read<AppUserCubit>().state
                                    as AppUserLoggedIn)
                                .user
                                .email,
                          );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Did not receive token? ',
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                        children: [
                          TextSpan(
                            text: 'Re-send',
                            style: context.theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
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
            'We\'ve sent an email containing the token to activate your account',
        style: context.theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
