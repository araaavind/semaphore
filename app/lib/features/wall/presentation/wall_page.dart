import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WallPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const WallPage());

  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semaphore'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<AppUserCubit, AppUserState>(
            builder: (context, state) {
              return Text(
                'Hi ${(state as AppUserLoggedIn).user.fullName}',
                style: context.theme.textTheme.displayLarge,
              );
            },
          ),
        ],
      ),
    );
  }
}
