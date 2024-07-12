import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:app/features/wall/presentation/wall_page.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<FeedBloc>(),
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
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCurrentUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.light,
      dark: AppTheme.dark,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Semaphore',
        theme: theme,
        darkTheme: darkTheme,
        home: BlocSelector<AppUserCubit, AppUserState, bool>(
          selector: (state) {
            return state is AppUserLoggedIn;
          },
          builder: (context, isLoggedIn) {
            if (isLoggedIn) {
              return const WallPage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
