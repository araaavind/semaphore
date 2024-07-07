import 'package:app/core/constants/constants.dart';
import 'package:app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/user_login.dart';
import 'package:app/features/auth/domain/usecases/user_signup.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smphr_sdk/smphr_sdk.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
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
    () => UserSignup(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => UserLogin(
      serviceLocator(),
    ),
  );
  // Register blocs
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignup: serviceLocator(),
      userLogin: serviceLocator(),
    ),
  );
}
