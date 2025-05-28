part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _setConfig();

  _initAuth();
  _initFeed();
  await _initSdk();
  await _initSharedPrefs();

  // Initialize Hive
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
  serviceLocator.registerLazySingleton(() => Hive.box());

  // Core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => NetworkCubit());

  serviceLocator.registerSingletonAsync<PackageInfo>(
    () => PackageInfo.fromPlatform(),
  );
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

  // Register user preferences service
  serviceLocator.registerLazySingleton(
    () => UserPreferencesService(prefsWithCache),
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
      () => LoginWithGoogle(
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
    ..registerFactory(
      () => UpdateUsername(
        serviceLocator(),
      ),
    )
    // Register blocs
    ..registerLazySingleton(
      () => AuthBloc(
        getCurrentUser: serviceLocator(),
        checkUsername: serviceLocator(),
        updateUsername: serviceLocator(),
        userSignup: serviceLocator(),
        userLogin: serviceLocator(),
        userLogout: serviceLocator(),
        loginWithGoogle: serviceLocator(),
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
    ..registerFactory<FeedLocalDatasource>(
      () => FeedLocalDatasourceImpl(
        serviceLocator(),
      ),
    )
    // Register repository
    ..registerFactory<FeedRepository>(
      () => FeedRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Register usecases
    ..registerFactory(
      () => ListTopics(
        serviceLocator(),
      ),
    )
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
    ..registerFactory(
      () => PinWall(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UnpinWall(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SaveItem(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UnsaveItem(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetSavedItems(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CheckUserSavedItems(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => LikeItem(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UnlikeItem(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetLikedItems(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CheckUserLikedItems(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetLikeCount(
        serviceLocator(),
      ),
    )
    // Register cubits
    ..registerFactory(
      () => ScrollToTopCubit(),
    )
    // Register blocs
    ..registerFactory(
      () => TopicsBloc(
        listTopics: serviceLocator(),
      ),
    )
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
        createWall: serviceLocator(),
        updateWall: serviceLocator(),
        deleteWall: serviceLocator(),
        pinWall: serviceLocator(),
        unpinWall: serviceLocator(),
        userPreferencesService: serviceLocator(),
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
        listFeeds: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SavedItemsBloc(
        saveItem: serviceLocator(),
        unsaveItem: serviceLocator(),
        getSavedItems: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => LikedItemsBloc(
        likeItem: serviceLocator(),
        unlikeItem: serviceLocator(),
      ),
    );
}
