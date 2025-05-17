import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/feed/presentation/widgets/profile_feed_list.dart';
import 'package:app/features/feed/presentation/widgets/profile_wall_list.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isActivated = false;
  late User user;
  late TabController _tabController;
  final double _expandedHeight = 180.0;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
    isActivated = user.isActivated;
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > (_expandedHeight * 0.6) && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (_scrollController.offset <= (_expandedHeight * 0.6) &&
          _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Method to handle logout
  void _handleLogout(BuildContext context, User user) {
    context.read<AuthBloc>().add(
          AuthLogoutRequested(
            user: user,
            scope: LogoutScope.local,
          ),
        );
  }

  List<Widget> _buildActions(BuildContext context, User user) {
    return [
      IconButton(
        onPressed: () {
          context.pushNamed(RouteConstants.savedItemsPageName);
        },
        icon: const Icon(MingCute.bookmarks_line),
      ),
      BlocConsumer<AuthBloc, AuthState>(
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
              height: 48,
              width: 48,
              child: Center(
                child: SizedBox(
                  height: 14,
                  width: 14,
                  child: Loader(
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          return PopupMenuButton<String>(
            icon: const Icon(MingCute.more_2_fill),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context, user);
              }
            },
            offset: const Offset(-18, 52),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(MingCute.exit_line, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: _expandedHeight + (isActivated ? 0 : 36),
              elevation: 0,
              title: _isCollapsed
                  ? Text(
                      user.fullName?.split(' ').first ?? user.username,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
              actions: _buildActions(context, user),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.9],
                      colors: [
                        context.theme.colorScheme.surfaceContainer,
                        context.theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.pagePadding,
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 72),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (user.profileImageURL != null &&
                                  user.profileImageURL!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 20.0,
                                  ),
                                  child: CircleAvatar(
                                    radius: 36,
                                    backgroundImage: CachedNetworkImageProvider(
                                      user.profileImageURL ?? '',
                                      cacheKey: 'profile-picture',
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      user.fullName ?? 'User',
                                      style: context.theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                      minFontSize: 16,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '@${user.username}',
                                      style: context.theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!isActivated)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20.0,
                              ),
                              child: Button(
                                text: 'Activate your account',
                                width: double.infinity,
                                backgroundColor:
                                    context.theme.colorScheme.primaryContainer,
                                textColor: context.theme.colorScheme.primary,
                                onPressed: () async {
                                  final routeSuccess = await context.push(
                                          RouteConstants.activationPagePath)
                                      as bool;
                                  if (routeSuccess) {
                                    setState(() {
                                      isActivated = true;
                                    });
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Walls'),
                    Tab(text: 'Feeds'),
                  ],
                  labelStyle: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle:
                      context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: context.theme.colorScheme.onSurface,
                  dividerColor:
                      context.theme.colorScheme.onSurface.withOpacity(0.1),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            ProfileWallList(),
            ProfileFeedList(),
          ],
        ),
      ),
    );
  }
}

// Custom delegate for persistent tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar, {this.backgroundColor});

  final TabBar _tabBar;
  final Color? backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
