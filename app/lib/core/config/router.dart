import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/features/auth/presentation/pages/choose_username_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
import 'package:app/features/home/presentation/home_page.dart';
import 'package:app/features/wall/presentation/wall_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final appUserState = context.read<AppUserCubit>().state;
    final onLoginRoute = state.topRoute!.name == 'login';
    final onUsernameRoute = state.topRoute!.name == 'username';
    final onSignupRoute = state.topRoute!.name == 'signup';

    if (appUserState is AppUserInitial &&
        !onLoginRoute &&
        !onUsernameRoute &&
        !onSignupRoute) {
      return '/login';
    }
    if (appUserState is AppUserLoggedIn && onLoginRoute) {
      return '/';
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
          path: '/',
          name: 'wall',
          builder: (context, state) => const WallPage(),
        ),
        GoRoute(
          path: '/feeds',
          name: 'feeds',
          builder: (context, state) => const SearchFeedsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final isOnboarding =
            state.uri.queryParameters['isOnboarding'] != null &&
                state.uri.queryParameters['isOnboarding'] == 'true';
        return LoginPage(isOnboarding: isOnboarding);
      },
      routes: [
        GoRoute(
          path: 'create-username',
          name: 'username',
          builder: (context, state) => const ChooseUsernamePage(),
          routes: [
            GoRoute(
              path: 'signup/:username',
              name: 'signup',
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
