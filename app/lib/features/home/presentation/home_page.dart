import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/widgets/loader.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
import 'package:app/features/wall/presentation/wall_page.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
    return BlocProvider(
      create: (_) => serviceLocator<FeedBloc>()..add(FeedSearchRequested()),
      lazy: false,
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
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
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
    );
  }
}
