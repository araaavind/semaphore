import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/entities/logout_scope.dart';
import 'package:app/core/common/widgets/loader.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WallPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const WallPage());

  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semaphore'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    AuthLogoutRequested(
                      user: user,
                      scope: LogoutScope.local,
                    ),
                  );
            },
            icon: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  showSnackbar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const SizedBox(
                    height: 14,
                    width: 14,
                    child: Loader(
                      strokeWidth: 2,
                    ),
                  );
                }
                return const Icon(Icons.logout);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hi ${user.fullName}',
              style: context.theme.textTheme.displayLarge,
            )
          ],
        ),
      ),
    );
  }
}
