import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/check_username.dart';
import 'package:app/features/auth/domain/usecases/get_current_user.dart';
import 'package:app/features/auth/domain/usecases/user_login.dart';
import 'package:app/features/auth/domain/usecases/user_logout.dart';
import 'package:app/features/auth/domain/usecases/user_signup.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:app/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:app/features/feed/domain/repositories/feed_repository.dart';
import 'package:app/features/feed/domain/usecases/list_feeds.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
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
  serviceLocator.registerLazySingleton(() => semaphore.client);

  // Core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
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
  // Register blocs
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      getCurrentUser: serviceLocator(),
      checkUsername: serviceLocator(),
      userSignup: serviceLocator(),
      userLogin: serviceLocator(),
      userLogout: serviceLocator(),
      appUserCubit: serviceLocator(),
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
  // Register blocs
  serviceLocator.registerLazySingleton(
    () => FeedBloc(
      listFeeds: serviceLocator(),
    ),
  );
}
