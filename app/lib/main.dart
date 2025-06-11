import 'dart:async';

import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/router/router.dart';
import 'package:app/core/services/analytics_service.dart';
import 'package:app/features/auth/presentation/cubit/activate_user/activate_user_cubit.dart';
import 'package:app/features/auth/presentation/cubit/reset_password/reset_password_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/init_dependencies.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smphr_sdk/smphr_sdk.dart' as sp;
import 'firebase_options.dart';

import 'core/theme/theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Analytics
  await AnalyticsService.initialize();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<NetworkCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ActivateUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ResetPasswordCubit>(),
        ),
      ],
      child: const SemaphoreApp(),
    ),
  );
}

class SemaphoreApp extends StatefulWidget {
  const SemaphoreApp({super.key});

  @override
  State<SemaphoreApp> createState() => _SemaphoreAppState();
}

class _SemaphoreAppState extends State<SemaphoreApp> {
  late StreamSubscription<sp.NetworkStatus> _networkStatusSubscription;
  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    super.initState();

    // Start analytics session
    AnalyticsService.startSession();

    _networkStatusSubscription =
        serviceLocator<sp.SemaphoreClient>().networkStatus.listen(
      (status) {
        switch (status) {
          case sp.NetworkStatus.connected:
            context.read<NetworkCubit>().updateNetworkStatus(
                  NetworkStatus.connected,
                );
            break;
          case sp.NetworkStatus.disconnected:
            context.read<NetworkCubit>().updateNetworkStatus(
                  NetworkStatus.disconnected,
                );
            break;
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print("Error in network status stream: $error");
        }
      },
    );

    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        serviceLocator<sp.SemaphoreClient>().resumeNetworkListener();
        AnalyticsService.startSession();
      },
      onPause: () {
        serviceLocator<sp.SemaphoreClient>().pauseNetworkListener();
        AnalyticsService.endSession();
      },
    );

    context.read<AuthBloc>().add(AuthCurrentUserRequested());

    Future.delayed(const Duration(milliseconds: 300), () {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    AnalyticsService.endSession();
    _networkStatusSubscription.cancel();
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.light,
      dark: AppTheme.dark,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarContrastEnforced: true,
            systemNavigationBarIconBrightness:
                theme.brightness == Brightness.light
                    ? Brightness.dark
                    : Brightness.light,
          ),
          child: BlocListener<AppUserCubit, AppUserState>(
            listener: (context, state) => router.refresh(),
            child: MaterialApp.router(
              routerConfig: router,
              title: 'Semaphore',
              theme: theme,
              darkTheme: darkTheme,
            ),
          ),
        );
      },
    );
  }
}
