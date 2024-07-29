import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hi ${user.fullName}',
              style: context.theme.textTheme.displayMedium,
            )
          ],
        ),
      ),
    );
  }
}
