import 'dart:ui';

import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/feed/utils/show_wall_filter_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WallPageSliverAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const WallPageSliverAppBarBottom({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kBottomNavigationBarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: BlocBuilder<WallsBloc, WallsState>(
        builder: (context, state) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AppBar(
                automaticallyImplyLeading:
                    false, // this will hide Drawer hamburger icon
                backgroundColor: context
                    .theme.colorScheme.surfaceContainerHighest
                    .withAlpha(217),

                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  side: BorderSide(
                    width: 0.8,
                    color: context.theme.colorScheme.onSurface.withAlpha(20),
                  ),
                ),
                toolbarHeight: kToolbarHeight - 8,
                title: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Icon(
                          MingCute.right_small_fill,
                          color: context.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          state.currentWall?.name ?? '',
                          style: context.theme.textTheme.bodyLarge?.copyWith(
                            color: context.theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                    ],
                  ),
                ),
                actions: [
                  if (state.currentWall != null &&
                      !state.currentWall!.isPrimary)
                    if (state.pinnedWallId == state.currentWall!.id)
                      IconButton(
                        onPressed: () {
                          context.read<WallsBloc>().add(UnpinWallRequested(
                              wallId: state.currentWall!.id));
                        },
                        icon: const Icon(MingCute.pin_2_fill),
                      )
                    else
                      IconButton(
                        onPressed: () {
                          context.read<WallsBloc>().add(
                              PinWallRequested(wallId: state.currentWall!.id));
                        },
                        icon: const Icon(MingCute.pin_2_line),
                      ),
                  if (state.currentWall != null &&
                      !state.currentWall!.isPrimary)
                    IconButton(
                      onPressed: () {
                        context.pushNamed(
                          RouteConstants.wallEditPageName,
                          pathParameters: {
                            'wallId': state.currentWall!.id.toString()
                          },
                          extra: state.currentWall,
                        );
                      },
                      icon: const Icon(MingCute.pencil_line),
                      color: context.theme.colorScheme.onSurface.withAlpha(217),
                    ),
                  IconButton(
                    padding: const EdgeInsets.only(right: 12.0),
                    onPressed: () {
                      showWallFilterModal(context);
                    },
                    icon: const Icon(Icons.filter_list),
                    color: context.theme.colorScheme.onSurface.withAlpha(217),
                  ),
                ],
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),
          );
        },
      ),
    );
  }
}
