part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _setConfig();

  _initAuth();
  _initFeed();
  await _initSdk();
  await _initSharedPrefs();
  // Core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => NetworkCubit());
}

void _setConfig() {
  EquatableConfig.stringify = true;
}

Future<void> _initSdk() async {
  // Register shared preferences for storing session
  serviceLocator.registerLazySingleton<LocalStorage>(
    () => SharedPreferencesLocalStorage(
      persistSessionKey: ServerConstants.persistSessionKey,
    ),
  );
  // Register semaphore sdk
  final semaphore = await Semaphore.initialize(
    baseUrl: ServerConstants.baseUrl,
    sharedLocalStorage: serviceLocator(),
  );
  serviceLocator.registerLazySingleton(
    () => semaphore.client,
    dispose: (param) {
      param.dispose();
    },
  );
}

Future<void> _initSharedPrefs() async {
  final prefsWithCache = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  serviceLocator.registerLazySingleton<SharedPreferencesWithCache>(
    () => prefsWithCache,
  );
}

void _initAuth() {
  serviceLocator
    // Register datasources
    ..registerFactory<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    // Register repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Register usecases
    ..registerFactory(
      () => GetCurrentUser(
        serviceLocator(),
      ),
    )
    // Register usecases
    ..registerFactory(
      () => CheckUsername(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignup(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogout(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ActivateUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SendActivationToken(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SendPasswordResetToken(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ResetPassword(
        serviceLocator(),
      ),
    )
    // Register blocs
    ..registerLazySingleton(
      () => AuthBloc(
        getCurrentUser: serviceLocator(),
        checkUsername: serviceLocator(),
        userSignup: serviceLocator(),
        userLogin: serviceLocator(),
        userLogout: serviceLocator(),
        appUserCubit: serviceLocator(),
        client: serviceLocator(),
      ),
    )
    // Register cubits
    ..registerLazySingleton(
      () => ActivateUserCubit(
        activateUser: serviceLocator(),
        sendActivationToken: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ResetPasswordCubit(
        sendPasswordResetToken: serviceLocator(),
        resetPassword: serviceLocator(),
      ),
    );
}

void _initFeed() {
  serviceLocator
    // Register datasources
    ..registerFactory<FeedRemoteDatasource>(
      () => FeedRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    // Register repository
    ..registerFactory<FeedRepository>(
      () => FeedRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Register usecases
    ..registerFactory(
      () => ListFeeds(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListFeedsForCurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CheckUserFollowsFeeds(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddFollowFeed(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => FollowFeed(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UnfollowFeed(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListFollowersOfFeed(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListWalls(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListItems(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CreateWall(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateWall(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => DeleteWall(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddFeedToWall(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => RemoveFeedFromWall(
        serviceLocator(),
      ),
    )
    // Register cubits
    ..registerFactory(
      () => WallCubit(
        createWall: serviceLocator(),
        updateWall: serviceLocator(),
        deleteWall: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ScrollToTopCubit(),
    )
    // Register blocs
    ..registerFactory(
      () => SearchFeedBloc(
        checkUserFollowsFeeds: serviceLocator(),
        listFeeds: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => FollowFeedBloc(
        followFeed: serviceLocator(),
        unfollowFeed: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddFollowFeedBloc(
        addFollowFeed: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListFollowersBloc(
        listFollowers: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => WallsBloc(
        listWalls: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListItemsBloc(
        listItems: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => WallFeedBloc(
        addFeedToWall: serviceLocator(),
        removeFeedFromWall: serviceLocator(),
      ),
    );
}
