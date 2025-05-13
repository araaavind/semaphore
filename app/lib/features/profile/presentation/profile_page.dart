import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isActivated = false;
  late User user;

  @override
  void initState() {
    super.initState();
    user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
    isActivated = user.isActivated;
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UIConstants.appBarTitle,
          style: context.theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w900,
            color: context.theme.brightness == Brightness.dark
                ? AppPalette.brandDark
                : AppPalette.brand,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouteConstants.savedItemsPageName);
            },
            icon: const Icon(MingCute.bookmarks_line),
          ),
          IconButton(
            onPressed: () {
              final user =
                  (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
              context.read<AuthBloc>().add(
                    AuthLogoutRequested(
                      user: user,
                      scope: LogoutScope.local,
                    ),
                  );
            },
            icon: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  showSnackbar(
                    context,
                    state.message,
                    type: SnackbarType.failure,
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const SizedBox(
                    height: 14,
                    width: 14,
                    child: Loader(
                      strokeWidth: 2,
                    ),
                  );
                }
                return const Icon(MingCute.exit_line);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: UIConstants.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName ?? 'User',
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '@${user.username}',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            if (!isActivated)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: UIConstants.elementGap),
                    Button(
                      text: 'Activate your account',
                      width: double.infinity,
                      backgroundColor:
                          context.theme.colorScheme.primaryContainer,
                      textColor: context.theme.colorScheme.primary,
                      onPressed: () async {
                        final routeSuccess = await context
                            .push(RouteConstants.activationPagePath) as bool;
                        if (routeSuccess) {
                          setState(() {
                            isActivated = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
