import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/activate_user.dart';
import 'package:app/features/auth/domain/usecases/check_username.dart';
import 'package:app/features/auth/domain/usecases/get_current_user.dart';
import 'package:app/features/auth/domain/usecases/send_activation_token.dart';
import 'package:app/features/auth/domain/usecases/user_login.dart';
import 'package:app/features/auth/domain/usecases/user_logout.dart';
import 'package:app/features/auth/domain/usecases/user_signup.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/cubit/activate_user/activate_user_cubit.dart';
import 'package:app/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:app/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:app/features/feed/domain/usecases/add_follow_feed.dart';
import 'package:app/features/feed/domain/usecases/check_user_follows_feeds.dart';
import 'package:app/features/feed/domain/usecases/follow_feed.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:app/features/feed/domain/usecases/list_feeds_for_current_user.dart';
import 'package:app/features/feed/domain/usecases/list_followers_of_feed.dart';
import 'package:app/features/feed/domain/usecases/list_items.dart';
import 'package:app/features/feed/domain/usecases/list_walls.dart';
import 'package:app/features/feed/domain/usecases/unfollow_feed.dart';
import 'package:app/features/feed/presentation/bloc/follow_feed/follow_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_followers/list_followers_bloc.dart';
import 'package:app/features/feed/presentation/bloc/list_items/list_items_bloc.dart';
import 'package:app/features/feed/presentation/bloc/search_feed/search_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:smphr_sdk/smphr_sdk.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _setConfig();

  _initAuth();
  _initFeed();
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

  // Core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => NetworkCubit());
}

void _setConfig() {
  EquatableConfig.stringify = true;
}

void _initAuth() {
  // Register datasources
  serviceLocator.registerFactory<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      serviceLocator(),
    ),
  );
  // Register repository
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
    ),
  );
  // Register usecases
  serviceLocator.registerFactory(
    () => GetCurrentUser(
      serviceLocator(),
    ),
  );
  // Register usecases
  serviceLocator.registerFactory(
    () => CheckUsername(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserSignup(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserLogin(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserLogout(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ActivateUser(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => SendActivationToken(
      serviceLocator(),
    ),
  );
  // Register blocs
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      getCurrentUser: serviceLocator(),
      checkUsername: serviceLocator(),
      userSignup: serviceLocator(),
      userLogin: serviceLocator(),
      userLogout: serviceLocator(),
      appUserCubit: serviceLocator(),
      client: serviceLocator(),
    ),
  );
  // Register cubits
  serviceLocator.registerLazySingleton(
    () => ActivateUserCubit(
      activateUser: serviceLocator(),
      sendActivationToken: serviceLocator(),
    ),
  );
}

void _initFeed() {
  // Register datasources
  serviceLocator.registerFactory<FeedRemoteDatasource>(
    () => FeedRemoteDatasourceImpl(
      serviceLocator(),
    ),
  );
  // Register repository
  serviceLocator.registerFactory<FeedRepository>(
    () => FeedRepositoryImpl(
      serviceLocator(),
    ),
  );
  // Register usecases
  serviceLocator.registerFactory(
    () => ListFeeds(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ListFeedsForCurrentUser(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => CheckUserFollowsFeeds(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => AddFollowFeed(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => FollowFeed(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UnfollowFeed(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ListFollowersOfFeed(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ListWalls(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ListItems(
      serviceLocator(),
    ),
  );
  // Register blocs
  serviceLocator.registerFactory(
    () => SearchFeedBloc(
      checkUserFollowsFeeds: serviceLocator(),
      listFeeds: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => FollowFeedBloc(
      followFeed: serviceLocator(),
      unfollowFeed: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => AddFollowFeedBloc(
      addFollowFeed: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ListFollowersBloc(
      listFollowers: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => WallsBloc(
      listWalls: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ListItemsBloc(
      listItems: serviceLocator(),
    ),
  );
}
