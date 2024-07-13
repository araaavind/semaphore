import 'package:app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:app/core/common/widgets/loader.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/feed/presentation/pages/search_feeds_page.dart';
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
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, SearchFeedsPage.route()),
            icon: const Icon(Icons.search),
          ),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                showSnackbar(context, state.message);
              }
            },
            builder: (context, state) {
              return state is AuthLoading
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        height: 14,
                        width: 14,
                        child: Loader(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        if (state is AuthSuccess) {
                          LogoutScope scope = LogoutScope.local;
                          context.read<AuthBloc>().add(
                                AuthLogoutEvent(
                                  user: state.user,
                                  scope: scope,
                                ),
                              );
                        }
                      },
                      icon: const Icon(Icons.logout),
                    );
            },
          ),
        ],
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
