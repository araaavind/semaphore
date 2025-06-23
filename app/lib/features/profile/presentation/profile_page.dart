import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/entities/user.dart';
import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/feed/presentation/widgets/profile_feed_list.dart';
import 'package:app/features/feed/presentation/widgets/profile_wall_list.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  // Build the right side drawer
  Widget _buildEndDrawer(BuildContext context, User user) {
    return Drawer(
      elevation: 6.0,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      shadowColor: Colors.black.withAlpha(160),
      width: MediaQuery.of(context).size.width * 0.65,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  _buildThemeSelector(context),
                  const SizedBox(height: 100),
                  Divider(
                    color: context.theme.colorScheme.outline.withAlpha(180),
                  ),
                  _buildAboutTile(context),
                ],
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
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Loader(strokeWidth: 2),
                      ),
                    );
                  }
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        UIConstants.inputBorderRadius,
                      ),
                    ),
                    leading: const Icon(
                      MingCute.exit_line,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Logout',
                      style: context.theme.textTheme.titleMedium,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    horizontalTitleGap: 12,
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      showConfirmationDialog(
                        context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                      ).then((value) {
                        if (value == true) {
                          Navigator.of(context).pop(); // Close drawer
                          _handleLogout(context, user);
                        }
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
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
      IconButton(
        icon: const Icon(MingCute.more_2_fill),
        onPressed: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: _buildEndDrawer(context, user),
      drawerScrimColor:
          context.theme.colorScheme.surfaceContainer.withAlpha(180),
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
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.fullName?.split(' ').first ?? user.username,
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (user.isAdmin == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.shield_outlined,
                              color: context.theme.brightness == Brightness.dark
                                  ? Colors.green
                                  : Colors.green.shade600,
                              size: 18,
                            ),
                          ),
                      ],
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
                        AppPalette.appBarGradientColor
                            .withLightness(
                              context.theme.brightness == Brightness.dark
                                  ? 0.75
                                  : 0.3,
                            )
                            .toColor(),
                        context.theme.brightness == Brightness.dark
                            ? context.theme.colorScheme.surface.withAlpha(0)
                            : context.theme.colorScheme.surface.withAlpha(0),
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
                                      cacheKey: user.email,
                                    ),
                                    onBackgroundImageError:
                                        (exception, stackTrace) {
                                      if (kDebugMode) {
                                        print(exception);
                                      }
                                    },
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: AutoSizeText(
                                            user.fullName ?? 'User',
                                            style: context
                                                .theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                            ),
                                            minFontSize: 16,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (user.isAdmin == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: context
                                                  .theme.colorScheme.onSurface
                                                  .withAlpha(20),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                UIConstants.inputBorderRadius,
                                              ),
                                              border: Border.all(
                                                color:
                                                    context.theme.brightness ==
                                                            Brightness.dark
                                                        ? Colors.green
                                                        : Colors.green.shade600,
                                              ),
                                            ),
                                            child: Text(
                                              'Admin',
                                              style: context
                                                  .theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    context.theme.brightness ==
                                                            Brightness.dark
                                                        ? Colors.green
                                                        : Colors.green.shade600,
                                              ),
                                            ),
                                          )
                                      ],
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
                                textColor: context
                                    .theme.colorScheme.onPrimaryContainer,
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
                    Tab(text: 'Feeds'),
                    Tab(text: 'Walls'),
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
                      context.theme.colorScheme.onSurface.withAlpha(25),
                ),
                backgroundColor: context.theme.colorScheme.surface,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            _KeepAliveTabView(child: ProfileFeedList()),
            _KeepAliveTabView(child: ProfileWallList()),
          ],
        ),
      ),
    );
  }

  // Build the theme selector section
  Widget _buildThemeSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              const Icon(MingCute.paint_2_line, color: Colors.pink),
              const SizedBox(width: 12),
              Text(
                'Theme',
                style: context.theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildThemeOption(
                  context,
                  'Light',
                  Icons.light_mode_outlined,
                  AdaptiveThemeMode.light,
                ),
                _buildThemeOption(
                  context,
                  'Dark',
                  Icons.dark_mode_outlined,
                  AdaptiveThemeMode.dark,
                ),
                _buildThemeOption(
                  context,
                  'System',
                  Icons.settings_suggest_outlined,
                  AdaptiveThemeMode.system,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build each theme option tile
  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    AdaptiveThemeMode themeMode,
  ) {
    final currentMode = AdaptiveTheme.of(context).mode;
    final isSelected = currentMode == themeMode;

    return InkWell(
      onTap: () {
        switch (themeMode) {
          case AdaptiveThemeMode.light:
            AdaptiveTheme.of(context).setLight();
            break;
          case AdaptiveThemeMode.dark:
            AdaptiveTheme.of(context).setDark();
            break;
          case AdaptiveThemeMode.system:
            AdaptiveTheme.of(context).setSystem();
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.theme.colorScheme.primaryContainer
              : context.theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(UIConstants.inputBorderRadius),
          border: Border.all(
            color: isSelected
                ? context.theme.colorScheme.primary.withAlpha(217)
                : context.theme.colorScheme.outline.withAlpha(166),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? context.theme.colorScheme.onPrimaryContainer
                  : context.theme.colorScheme.onSurface,
            ),
            // const SizedBox(width: 8),
            // Text(
            //   title,
            //   style: context.theme.textTheme.bodyMedium?.copyWith(
            //     color: isSelected
            //         ? context.theme.colorScheme.onPrimaryContainer
            //         : context.theme.colorScheme.onSurface,
            //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

Widget _buildAboutTile(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pop(); // Close drawer first
      context.pushNamed(
          RouteConstants.aboutPageName); // Navigate to the about page
    },
    borderRadius: BorderRadius.circular(UIConstants.inputBorderRadius),
    child: Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(MingCute.heart_line,
              color: context.theme.brightness == Brightness.dark
                  ? Colors.amber
                  : Colors.amber.shade700),
          const SizedBox(width: 12),
          Text(
            'About Semaphore',
            style: context.theme.textTheme.titleMedium,
          ),
        ],
      ),
    ),
  );
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
    return backgroundColor != oldDelegate.backgroundColor ||
        _tabBar != oldDelegate._tabBar;
  }
}

// Add this new widget at the end of the file, before the _SliverTabBarDelegate class
class _KeepAliveTabView extends StatefulWidget {
  final Widget child;

  const _KeepAliveTabView({required this.child});

  @override
  State<_KeepAliveTabView> createState() => _KeepAliveTabViewState();
}

class _KeepAliveTabViewState extends State<_KeepAliveTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
