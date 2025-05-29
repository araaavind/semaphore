import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/core/common/cubits/scroll_to_top/scroll_to_top_cubit.dart';
import 'package:app/features/feed/presentation/bloc/topics/topics_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final Widget child;
  const HomePage({required this.child, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Preload topic images when topics are available
    Future.delayed(Duration.zero, () {
      final topicsStateStream = context.read<TopicsBloc>().stream;

      Map<String, ImageProvider> providers = {};
      topicsStateStream.listen((topicsState) {
        if (topicsState.status == TopicsStatus.loaded) {
          for (final topic in topicsState.topics
              .where((t) => t.featured && t.imageUrl != null)) {
            final provider = CachedNetworkImageProvider(
              topic.imageUrl!,
              cacheKey: topic.code,
              maxWidth: (MediaQuery.of(context).size.width / 2).toInt(),
            );
            precacheImage(provider, context);
            providers[topic.code] = provider;
          }
          context
              .read<TopicsBloc>()
              .add(SetTopicImageProviders(imageProviders: providers));
        }
      });
    });
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        if (GoRouterState.of(context).topRoute!.name ==
            RouteConstants.wallPageName) {
          context.read<ScrollToTopCubit>().scrollToTopRequested();
        } else {
          context.goNamed(RouteConstants.wallPageName);
        }
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
    return NestedScaffoldMessenger(
      child: Scaffold(
        body: BlocListener<NetworkCubit, NetworkState>(
          listener: (context, state) {
            switch (state.status) {
              case NetworkStatus.connected:
                showSnackbar(
                  context,
                  TextConstants.networkConnectedMessage,
                  type: SnackbarType.success,
                );
                break;
              case NetworkStatus.disconnected:
                showSnackbar(
                  context,
                  TextConstants.networkDisconnectedMessage,
                  type: SnackbarType.failure,
                );
                break;
            }
          },
          child: widget.child,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 54,
            child: Wrap(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _calculateSelectedIndex(context),
                    onTap: (value) => _onItemTapped(value, context),
                    iconSize: 26.0,
                    items: const [
                      BottomNavigationBarItem(
                        label: 'Home',
                        icon: Icon(MingCute.home_4_line),
                        activeIcon: Icon(MingCute.home_4_fill),
                      ),
                      BottomNavigationBarItem(
                        label: 'Search',
                        icon: Icon(MingCute.search_line),
                        activeIcon: Icon(MingCute.search_fill),
                      ),
                      BottomNavigationBarItem(
                        label: 'Profile',
                        icon: Icon(MingCute.user_3_line),
                        activeIcon: Icon(MingCute.user_3_fill),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
