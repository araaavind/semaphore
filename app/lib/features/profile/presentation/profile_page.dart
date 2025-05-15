import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_palette.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          horizontal: UIConstants.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (user.profileImageURL != null &&
                    user.profileImageURL!.isNotEmpty)
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: CachedNetworkImageProvider(
                      user.profileImageURL ?? '',
                      cacheKey: 'profile-picture',
                    ),
                  ),
                if (user.profileImageURL != null &&
                    user.profileImageURL!.isNotEmpty)
                  const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: AutoSizeText(
                        user.fullName ?? 'User',
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        minFontSize: 16,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
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
