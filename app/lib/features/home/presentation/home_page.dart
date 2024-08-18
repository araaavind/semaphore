import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/theme/extensions/app_snackbar_color_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/wall/presentation/bloc/list_items_bloc.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  final Widget child;
  const HomePage({required this.child, super.key});

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(RouteConstants.wallPageName);
        break;
      case 1:
        context.goNamed(RouteConstants.searchFeedsPageName);
        break;
      case 2:
        context.goNamed(RouteConstants.profilePageName);
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String routeName = GoRouterState.of(context).topRoute!.name!;
    if (routeName == RouteConstants.wallPageName) {
      return 0;
    }
    if (routeName == RouteConstants.searchFeedsPageName) {
      return 1;
    }
    if (routeName == RouteConstants.profilePageName) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<SearchFeedBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<FollowFeedBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ListItemsBloc>(),
        ),
      ],
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
          body: child,
          bottomNavigationBar: Container(
            decoration:
                (context.theme.colorScheme.brightness == Brightness.dark)
                    ? BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: context.theme.colorScheme.outline,
                            width: UIConstants.borderWidth,
                          ),
                        ),
                      )
                    : null,
            child: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (value) => _onItemTapped(value, context),
              iconSize: 26.0,
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
                BottomNavigationBarItem(
                  label: 'Profile',
                  icon: Icon(Icons.person_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
