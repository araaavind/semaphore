import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/cubits/scroll_to_top/scroll_to_top_cubit.dart';
import 'package:app/core/common/pages/error_page.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/router/analytics_route_wrapper.dart';
import 'package:app/core/router/transitions/fade_transition_page.dart';
import 'package:app/core/router/transitions/slide_transition_page.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/pages/activation_page.dart';
import 'package:app/features/auth/presentation/pages/choose_username_page.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:app/features/auth/presentation/pages/send_reset_token_page.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/blocs.dart';
import 'package:app/features/feed/presentation/pages/add_feed_page.dart';
import 'package:app/features/feed/presentation/pages/add_to_wall_page.dart';
import 'package:app/features/feed/presentation/pages/create_wall_page.dart';
import 'package:app/features/feed/presentation/pages/feed_view_page.dart';
import 'package:app/features/feed/presentation/pages/saved_items_page.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
import 'package:app/features/feed/presentation/pages/web_view.dart';
import 'package:app/features/home/presentation/home_page.dart';
import 'package:app/features/profile/presentation/about_page.dart';
import 'package:app/features/profile/presentation/profile_page.dart';
import 'package:app/features/feed/presentation/pages/wall_page.dart';
import 'package:app/features/feed/presentation/pages/wall_edit_page.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  initialLocation: RouteConstants.loginPagePath,
  errorBuilder: (context, state) => const ErrorPage(),
  redirect: (context, state) => _redirectLogic(context, state),
  routes: _buildRoutes(),
);

String? _redirectLogic(BuildContext context, GoRouterState state) {
  final appUserState = context.read<AppUserCubit>().state;
  final onLoginRoute = state.topRoute!.name == RouteConstants.loginPageName;
  final onUsernameRoute =
      state.topRoute!.name == RouteConstants.usernamePageName;
  final onSignupRoute = state.topRoute!.name == RouteConstants.signupPageName;
  final onSendResetTokenRoute =
      state.topRoute!.name == RouteConstants.sendResetTokenPageName;
  final onResetPasswordRoute =
      state.topRoute!.name == RouteConstants.resetPasswordPageName;

  if (appUserState is AppUserInitial &&
      !onLoginRoute &&
      !onUsernameRoute &&
      !onSignupRoute &&
      !onSendResetTokenRoute &&
      !onResetPasswordRoute) {
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
}

List<RouteBase> _buildRoutes() {
  return [
    ShellRoute(
      builder: (context, state, child) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => serviceLocator<WallsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<SearchFeedBloc>(),
          ),
          BlocProvider(
            create: (context) => serviceLocator<AddFollowFeedBloc>(),
          ),
          BlocProvider(
            create: (context) => serviceLocator<FollowFeedBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<WallFeedBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<ListItemsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<ScrollToTopCubit>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<SavedItemsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<LikedItemsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<TopicsBloc>()
              // load saved topics for immediate use
              ..add(ListTopicsRequested(fromLocal: true))
              // load from remote and update local
              ..add(ListTopicsRequested(fromLocal: false)),
            lazy: false,
          ),
        ],
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final shouldPop = await showConfirmationDialog(
                  context,
                  title: 'Exit App',
                  message: 'Are you sure you want to exit the app?',
                ) ??
                false;

            if (shouldPop) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: child,
          ),
        ),
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return HomePage(child: child);
          },
          routes: <RouteBase>[
            _buildWallRoute(),
            _buildSearchFeedsRoute(),
            // _buildExploreRoute(),
            _buildProfileRoute(),
          ],
        ),
        _buildFeedViewRoute(),
        _buildFeedWebViewRoute(),
        _buildAddFeedRoute(),
        _buildAddToWallRoute(),
        _buildCreateWallRoute(),
        _buildWallEditRoute(),
        _buildSavedItemsRoute(),
        _buildAboutRoute(),
      ],
    ),
    _buildLoginRoute(),
    _buildActivationRoute(),
    _buildResetPasswordRoute(),
    _buildSendResetTokenRoute(),
  ];
}

GoRoute _buildFeedWebViewRoute() {
  return GoRoute(
    path: RouteConstants.webViewPagePath,
    name: RouteConstants.webViewPageName,
    pageBuilder: (context, state) {
      final url = state.uri.queryParameters['url'] ?? '';
      final itemId = state.uri.queryParameters['itemId'] ?? '-1';
      final isSaved = state.uri.queryParameters['isSaved'] != null &&
          state.uri.queryParameters['isSaved'] == 'true';
      final isLiked = state.uri.queryParameters['isLiked'] != null &&
          state.uri.queryParameters['isLiked'] == 'true';
      return SlideTransitionPage(
        key: const ValueKey('webview'),
        direction: SlideDirection.rightToLeft,
        child: AnalyticsRouteWrapper(
          routeName: RouteConstants.webViewPageName,
          routeClass: 'WebView',
          child: WebView(
            url: url,
            itemId: int.parse(itemId),
            isSaved: isSaved,
            isLiked: isLiked,
          ),
        ),
      );
    },
  );
}

GoRoute _buildCreateWallRoute() {
  return GoRoute(
    path: RouteConstants.createWallPagePath,
    name: RouteConstants.createWallPageName,
    builder: (context, state) {
      int? feedId;
      if (state.uri.queryParameters['feedId'] != null) {
        feedId = int.parse(state.uri.queryParameters['feedId']!);
      }
      return AnalyticsRouteWrapper(
        routeName: RouteConstants.createWallPageName,
        routeClass: 'CreateWallPage',
        child: CreateWallPage(feedId: feedId),
      );
    },
  );
}

GoRoute _buildAddToWallRoute() {
  return GoRoute(
    path: RouteConstants.addToWallPagePath,
    name: RouteConstants.addToWallPageName,
    builder: (context, state) {
      final feedId = int.parse(state.pathParameters['feedId'] ?? '0');

      return AnalyticsRouteWrapper(
        routeName: RouteConstants.addToWallPageName,
        routeClass: 'AddToWallPage',
        child: AddToWallPage(feedId: feedId),
      );
    },
  );
}

GoRoute _buildAddFeedRoute() {
  return GoRoute(
    path: RouteConstants.addFeedPagePath,
    name: RouteConstants.addFeedPageName,
    builder: (context, state) => AnalyticsRouteWrapper(
      routeName: RouteConstants.addFeedPageName,
      routeClass: 'AddFeedPage',
      child: const AddFeedPage(),
    ),
  );
}

GoRoute _buildActivationRoute() {
  return GoRoute(
    path: RouteConstants.activationPagePath,
    name: RouteConstants.activationPageName,
    builder: (context, state) {
      final isOnboarding = state.uri.queryParameters['isOnboarding'] != null &&
          state.uri.queryParameters['isOnboarding'] == 'true';
      return AnalyticsRouteWrapper(
        routeName: RouteConstants.activationPageName,
        routeClass: 'ActivationPage',
        child: ActivationPage(isOnboarding: isOnboarding),
      );
    },
  );
}

GoRoute _buildResetPasswordRoute() {
  return GoRoute(
    path: RouteConstants.resetPasswordPagePath,
    name: RouteConstants.resetPasswordPageName,
    builder: (context, state) {
      return AnalyticsRouteWrapper(
        routeName: RouteConstants.resetPasswordPageName,
        routeClass: 'ResetPasswordPage',
        child: const ResetPasswordPage(),
      );
    },
  );
}

GoRoute _buildSendResetTokenRoute() {
  return GoRoute(
    path: RouteConstants.sendResetTokenPagePath,
    name: RouteConstants.sendResetTokenPageName,
    builder: (context, state) => AnalyticsRouteWrapper(
      routeName: RouteConstants.sendResetTokenPageName,
      routeClass: 'SendResetTokenPage',
      child: const SendResetTokenPage(),
    ),
  );
}

GoRoute _buildLoginRoute() {
  return GoRoute(
    path: RouteConstants.loginPagePath,
    name: RouteConstants.loginPageName,
    builder: (context, state) {
      final isOnboarding = state.uri.queryParameters['isOnboarding'] != null &&
          state.uri.queryParameters['isOnboarding'] == 'true';
      return AnalyticsRouteWrapper(
        routeName: RouteConstants.loginPageName,
        routeClass: 'LoginPage',
        child: LoginPage(isOnboarding: isOnboarding),
      );
    },
    routes: [
      GoRoute(
        path: RouteConstants.usernamePagePath,
        name: RouteConstants.usernamePageName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isOAuthUser = extra != null && extra['isOAuthUser'] == true;
          return AnalyticsRouteWrapper(
            routeName: RouteConstants.usernamePageName,
            routeClass: 'ChooseUsernamePage',
            child: ChooseUsernamePage(isOAuthUser: isOAuthUser),
          );
        },
        routes: [
          GoRoute(
            path: RouteConstants.signupPagePath,
            name: RouteConstants.signupPageName,
            builder: (context, state) => AnalyticsRouteWrapper(
              routeName: RouteConstants.signupPageName,
              routeClass: 'SignupPage',
              child: SignupPage(
                username: state.pathParameters['username']!,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

GoRoute _buildProfileRoute() {
  return GoRoute(
    path: RouteConstants.profilePagePath,
    name: RouteConstants.profilePageName,
    pageBuilder: (context, state) => FadeTransitionPage(
      key: const ValueKey('profile'),
      child: AnalyticsRouteWrapper(
        routeName: RouteConstants.profilePageName,
        routeClass: 'ProfilePage',
        child: const ProfilePage(),
      ),
    ),
  );
}

GoRoute _buildSearchFeedsRoute() {
  return GoRoute(
    path: RouteConstants.searchFeedsPagePath,
    name: RouteConstants.searchFeedsPageName,
    pageBuilder: (context, state) {
      final isOnboarding = state.uri.queryParameters['isOnboarding'] != null &&
          state.uri.queryParameters['isOnboarding'] == 'true';
      return FadeTransitionPage(
        key: const ValueKey('feeds'),
        child: AnalyticsRouteWrapper(
          routeName: RouteConstants.searchFeedsPageName,
          routeClass: 'SearchFeedsPage',
          child: SearchFeedsPage(isOnboarding: isOnboarding),
        ),
      );
    },
  );
}

GoRoute _buildFeedViewRoute() {
  return GoRoute(
    path: RouteConstants.feedViewPagePath,
    name: RouteConstants.feedViewPageName,
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, Object>;
      final feed = extra['feed'] as Feed;
      final isFollowed = extra['isFollowed'] as bool;
      return SlideTransitionPage(
        key: const ValueKey(RouteConstants.feedViewPageName),
        direction: SlideDirection.rightToLeft,
        child: AnalyticsRouteWrapper(
          routeName: RouteConstants.feedViewPageName,
          routeClass: 'FeedViewPage',
          child: FeedViewPage(
            feed: feed,
            isFollowed: isFollowed,
          ),
        ),
      );
    },
  );
}

GoRoute _buildWallRoute() {
  return GoRoute(
    path: RouteConstants.wallPagePath,
    name: RouteConstants.wallPageName,
    pageBuilder: (context, state) => FadeTransitionPage(
      key: const ValueKey('wall'),
      child: AnalyticsRouteWrapper(
        routeName: RouteConstants.wallPageName,
        routeClass: 'WallPage',
        child: const WallPage(),
      ),
    ),
  );
}

GoRoute _buildWallEditRoute() {
  return GoRoute(
    path: RouteConstants.wallEditPagePath,
    name: RouteConstants.wallEditPageName,
    builder: (context, state) {
      return AnalyticsRouteWrapper(
        routeName: RouteConstants.wallEditPageName,
        routeClass: 'WallEditPage',
        child: WallEditPage(
          wall: state.extra as Wall,
        ),
      );
    },
  );
}

GoRoute _buildSavedItemsRoute() {
  return GoRoute(
    path: RouteConstants.savedItemsPagePath,
    name: RouteConstants.savedItemsPageName,
    builder: (context, state) => AnalyticsRouteWrapper(
      routeName: RouteConstants.savedItemsPageName,
      routeClass: 'SavedItemsPage',
      child: const SavedItemsPage(),
    ),
  );
}

GoRoute _buildAboutRoute() {
  return GoRoute(
    path: RouteConstants.aboutPagePath,
    name: RouteConstants.aboutPageName,
    builder: (context, state) => AnalyticsRouteWrapper(
      routeName: RouteConstants.aboutPageName,
      routeClass: 'AboutPage',
      child: const AboutPage(),
    ),
  );
}
