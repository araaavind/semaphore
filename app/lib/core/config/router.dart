import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/pages/error_page.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/auth/presentation/pages/choose_username_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
import 'package:app/features/home/presentation/home_page.dart';
import 'package:app/features/wall/presentation/wall_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  initialLocation: RouteConstants.wallPagePath,
  errorBuilder: (context, state) => const ErrorPage(),
  redirect: (context, state) {
    final appUserState = context.read<AppUserCubit>().state;
    final onLoginRoute = state.topRoute!.name == RouteConstants.loginPageName;
    final onUsernameRoute =
        state.topRoute!.name == RouteConstants.usernamePageName;
    final onSignupRoute = state.topRoute!.name == RouteConstants.signupPageName;

    if (appUserState is AppUserInitial &&
        !onLoginRoute &&
        !onUsernameRoute &&
        !onSignupRoute) {
      return RouteConstants.loginPagePath;
    }
    if (appUserState is AppUserLoggedIn && onLoginRoute) {
      return RouteConstants.wallPagePath;
    }
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.wallPagePath,
          name: RouteConstants.wallPageName,
          builder: (context, state) => const WallPage(),
        ),
        GoRoute(
          path: RouteConstants.searchFeedsPagePath,
          name: RouteConstants.searchFeedsPageName,
          builder: (context, state) {
            final isOnboarding =
                state.uri.queryParameters['isOnboarding'] != null &&
                    state.uri.queryParameters['isOnboarding'] == 'true';
            return SearchFeedsPage(isOnboarding: isOnboarding);
          },
        ),
      ],
    ),
    GoRoute(
      path: RouteConstants.loginPagePath,
      name: RouteConstants.loginPageName,
      builder: (context, state) {
        final isOnboarding =
            state.uri.queryParameters['isOnboarding'] != null &&
                state.uri.queryParameters['isOnboarding'] == 'true';
        return LoginPage(isOnboarding: isOnboarding);
      },
      routes: [
        GoRoute(
          path: RouteConstants.usernamePagePath,
          name: RouteConstants.usernamePageName,
          builder: (context, state) => const ChooseUsernamePage(),
          routes: [
            GoRoute(
              path: RouteConstants.signupPagePath,
              name: RouteConstants.signupPageName,
              builder: (context, state) => SignupPage(
                username: state.pathParameters['username']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
