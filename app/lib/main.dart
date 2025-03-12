import 'dart:async';

import 'package:app/core/common/cubits/network/network_cubit.dart';
import 'package:app/core/router/router.dart';
import 'package:app/features/auth/presentation/cubit/activate_user/activate_user_cubit.dart';
import 'package:app/core/common/cubits/scroll_to_top/scroll_to_top_cubit.dart';
import 'package:flutter/material.dart';
import 'package:app/init_dependencies.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smphr_sdk/smphr_sdk.dart' as sp;

import 'core/theme/theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
          create: (_) => serviceLocator<ScrollToTopCubit>(),
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

  @override
  void initState() {
    super.initState();
    _networkStatusSubscription =
        serviceLocator<sp.SemaphoreClient>().networkStatus.listen(
      (status) {
        context.read<NetworkCubit>().updateNetworkStatus(
              status == sp.NetworkStatus.connected,
            );
      },
    );

    context.read<AuthBloc>().add(AuthCurrentUserRequested());

    Future.delayed(const Duration(milliseconds: 300), () {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void dispose() {
    _networkStatusSubscription.cancel();
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
              debugShowCheckedModeBanner: false,
            ),
          ),
        );
      },
    );
  }
}
