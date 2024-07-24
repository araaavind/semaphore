import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/widgets/loader.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/theme/extensions/app_snackbar_color_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
import 'package:app/features/wall/presentation/wall_page.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final String initialRouteName;
  const HomePage({
    this.initialRouteName = RouteConstants.wallPageName,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;

  int _calculateSelectedIndex() {
    final String routeName = GoRouterState.of(context).topRoute!.name!;
    if (routeName == RouteConstants.wallPageName) {
      return 0;
    }
    if (routeName == RouteConstants.searchFeedsPageName) {
      return 1;
    }
    return 0;
  }

  void _onPageChanged(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    switch (index) {
      case 0:
        context.goNamed(RouteConstants.wallPageName);
        break;
      case 1:
        context.goNamed(RouteConstants.searchFeedsPageName);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    var initialPage = 0;
    switch (widget.initialRouteName) {
      case RouteConstants.wallPageName:
        initialPage = 0;
        break;
      case RouteConstants.searchFeedsPageName:
        initialPage = 1;
        break;
    }
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
    return BlocProvider(
      create: (_) => serviceLocator<FeedBloc>(),
      child: BlocListener<NetworkCubit, NetworkState>(
        listener: (context, state) {
          switch (state.status) {
            case NetworkStatus.connected:
              showSnackbar(
                context,
                TextConstants.networkConnectedMessage,
                backgroundColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOnlineContainer,
                textColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOnlineOnContainer,
              );
            case NetworkStatus.disconnected:
              showSnackbar(
                context,
                TextConstants.networkDisconnectedMessage,
                backgroundColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOfflineContainer,
                textColor: context.theme
                    .extension<AppSnackbarColorTheme>()!
                    .networkOfflineOnContainer,
              );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'smphr',
              style: context.theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w900,
                color: context.theme.colorScheme.primary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
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
                      showSnackbar(context, state.message);
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
                    return const Icon(Icons.logout);
                  },
                ),
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              WallPage(),
              SearchFeedsPage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.theme.colorScheme.outline,
                  width: 0.2,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(),
              onTap: _onPageChanged,
              iconSize: 30.0,
              items: const [
                BottomNavigationBarItem(
                  label: 'Home',
                  icon: Icon(Icons.home_outlined),
                  // activeIcon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  label: 'Search',
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
