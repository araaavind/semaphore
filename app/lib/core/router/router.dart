import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/pages/error_page.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/router/transitions/fade_transition_page.dart';
import 'package:app/core/router/transitions/slide_transition_page.dart';
import 'package:app/features/auth/presentation/pages/activation_page.dart';
import 'package:app/features/auth/presentation/pages/choose_username_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:app/features/feed/presentation/pages/add_feed_page.dart';
import 'package:app/features/feed/presentation/pages/feed_view_page.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
import 'package:app/features/feed/presentation/pages/web_view.dart';
import 'package:app/features/home/presentation/home_page.dart';
import 'package:app/features/profile/presentation/profile_page.dart';
import 'package:app/features/feed/presentation/pages/wall_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  initialLocation: RouteConstants.loginPagePath,
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
      final isOnboarding = state.uri.queryParameters['isOnboarding'] != null &&
          state.uri.queryParameters['isOnboarding'] == 'true';
      if (isOnboarding) {
        return '${RouteConstants.activationPagePath}?isOnboarding=$isOnboarding';
      }
      return RouteConstants.wallPagePath;
    }
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomePage(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
            path: RouteConstants.wallPagePath,
            name: RouteConstants.wallPageName,
            pageBuilder: (context, state) => FadeTransitionPage(
                  key: const ValueKey('wall'),
                  child: const WallPage(),
                ),
            routes: [
              GoRoute(
                path: RouteConstants.webViewPagePath,
                name: RouteConstants.webViewPageName,
                pageBuilder: (context, state) {
                  final url = state.uri.queryParameters['url'] ?? '';
                  return SlideTransitionPage(
                    key: const ValueKey('view'),
                    child: WebView(url: url),
                    direction: SlideDirection.bottomToTop,
                  );
                },
              ),
            ]),
        GoRoute(
          path: RouteConstants.searchFeedsPagePath,
          name: RouteConstants.searchFeedsPageName,
          pageBuilder: (context, state) {
            final isOnboarding =
                state.uri.queryParameters['isOnboarding'] != null &&
                    state.uri.queryParameters['isOnboarding'] == 'true';
            return FadeTransitionPage(
              key: const ValueKey('feeds'),
              child: SearchFeedsPage(isOnboarding: isOnboarding),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.profilePagePath,
          name: RouteConstants.profilePageName,
          pageBuilder: (context, state) => FadeTransitionPage(
            key: const ValueKey('profile'),
            child: const ProfilePage(),
          ),
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
    GoRoute(
      path: RouteConstants.activationPagePath,
      name: RouteConstants.activationPageName,
      builder: (context, state) {
        final isOnboarding =
            state.uri.queryParameters['isOnboarding'] != null &&
                state.uri.queryParameters['isOnboarding'] == 'true';
        return ActivationPage(isOnboarding: isOnboarding);
      },
    ),
    GoRoute(
      path: RouteConstants.feedViewPagePath,
      name: RouteConstants.feedViewPageName,
      builder: (context, state) {
        final extra = state.extra as Map<String, Object>;
        final feed = extra['feed'] as Feed;
        final followFeedBlocValue =
            extra['followFeedBlocValue'] as FollowFeedBloc;
        final listItemsBlocValue = extra['listItemsBlocValue'] as ListItemsBloc;
        final isFollowed = extra['isFollowed'] as bool;
        return FeedViewPage(
          feed: feed,
          followFeedBlocValue: followFeedBlocValue,
          listItemsBlocValue: listItemsBlocValue,
          isFollowed: isFollowed,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.addFeedPagePath,
      name: RouteConstants.addFeedPageName,
      builder: (context, state) => const AddFeedPage(),
    ),
  ],
);
