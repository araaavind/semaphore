import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/bloc/wall_feed/wall_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateWallPage extends StatefulWidget {
  final int? feedId;
  const CreateWallPage({super.key, this.feedId});

  @override
  State<CreateWallPage> createState() => _CreateWallPageState();
}

class _CreateWallPageState extends State<CreateWallPage> {
  final wallNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    wallNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(UIConstants.pagePadding),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TitleTextSpan(),
                const SizedBox(height: 20),
                AppTextField(
                  hintText: 'Wall name',
                  controller: wallNameController,
                  errorMaxLines: 2,
                  validator: _wallNameControllerValidator,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                Center(
                  child: BlocConsumer<WallsBloc, WallsState>(
                    listener: (context, state) {
                      if (state.status == WallStatus.success &&
                          state.action == WallAction.list) {
                        if (widget.feedId != null) {
                          final createdWall = state.walls
                              .where((wall) =>
                                  wall.name == wallNameController.text.trim())
                              .toList();
                          if (createdWall.isNotEmpty &&
                              createdWall.length == 1) {
                            context.read<WallFeedBloc>().add(
                                  AddFeedToWallRequested(
                                    feedId: widget.feedId!,
                                    wallId: createdWall.first.id,
                                  ),
                                );
                          }
                        }
                        context.pop(true);
                      }
                      if (state.status == WallStatus.failure &&
                          state.action == WallAction.create) {
                        if (state.fieldErrors != null &&
                            state.fieldErrors!['name'] != null) {
                          showSnackbar(
                            context,
                            state.fieldErrors!['name']!,
                            type: SnackbarType.failure,
                          );
                        } else {
                          showSnackbar(
                            context,
                            state.message!,
                            type: SnackbarType.failure,
                          );
                        }
                      }
                      if (state.status == WallStatus.success &&
                          state.action == WallAction.create) {
                        showSnackbar(
                          context,
                          'Wall created!',
                          type: SnackbarType.info,
                        );
                        context.read<WallsBloc>().add(
                              ListWallsRequested(refreshItems: false),
                            );
                      }
                    },
                    builder: (context, state) {
                      return Button(
                        text: 'Create',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            context.read<WallsBloc>().add(
                                  CreateWallRequested(
                                    wallName: wallNameController.text.trim(),
                                  ),
                                );
                          }
                        },
                        isLoading: state.status == WallStatus.loading &&
                            state.action == WallAction.create,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height:
                      Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight,
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  String? _wallNameControllerValidator(value) {
    if (value!.isEmpty) {
      return 'Wall name should not be blank';
    }
    return null;
  }
}

class _TitleTextSpan extends StatelessWidget {
  const _TitleTextSpan();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'create a new ',
        style: context.theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w100,
        ),
        children: [
          TextSpan(
            text: 'wall',
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
