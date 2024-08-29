import 'package:app/core/common/widgets/button.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddToWallPage extends StatelessWidget {
  const AddToWallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add to wall',
          style: context.theme.textTheme.titleMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(true);
            },
            style: const ButtonStyle(
              splashFactory: NoSplash.splashFactory,
            ),
            child: Row(
              children: [
                Text(
                  'Done',
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            Button(
              text: 'Create new Wall',
              backgroundColor: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
              onPressed: () async {
                final isCreated =
                    await context.pushNamed(RouteConstants.createWallPageName);
                if ((isCreated as bool) == true && context.mounted) {
                  context.read<WallsBloc>().add(ListWallsRequested());
                }
              },
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (int i = 0; i < 20; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Somethign'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        trailing: Builder(builder: (context) {
                          return Container(
                            height: 28.0,
                            width: 28.0,
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle_outline_rounded,
                                size: 28.0,
                                weight: 0.4,
                                color: context.theme.colorScheme.onSurface,
                              ),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                            ),
                          );
                        }),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
