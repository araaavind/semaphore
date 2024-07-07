import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
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
      ],
      child: const SemaphoreApp(),
    ),
  );
}

class SemaphoreApp extends StatelessWidget {
  const SemaphoreApp({super.key});

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
        home: const LoginPage(),
      ),
    );
  }
}
