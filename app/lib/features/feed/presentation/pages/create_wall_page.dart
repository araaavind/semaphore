import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/show_snackbar.dart';
import 'package:app/features/feed/presentation/cubit/create_wall/create_wall_cubit.dart';
import 'package:app/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateWallPage extends StatefulWidget {
  const CreateWallPage({super.key});

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
    return BlocProvider(
      create: (context) => serviceLocator<CreateWallCubit>(),
      child: Scaffold(
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
                    child: BlocConsumer<CreateWallCubit, CreateWallState>(
                      listener: (context, state) {
                        if (state.status == CreateWallStatus.failure) {
                          showSnackbar(
                            context,
                            state.message!,
                            type: SnackbarType.failure,
                          );
                        }
                        if (state.status == CreateWallStatus.success) {
                          showSnackbar(
                            context,
                            'Your wall has been created!',
                            type: SnackbarType.success,
                          );
                          context.pop(true);
                        }
                      },
                      builder: (context, state) {
                        return Button(
                          text: 'Create',
                          fixedSize: const Size(140, 50),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              context
                                  .read<CreateWallCubit>()
                                  .createWall(wallNameController.text.trim());
                            }
                          },
                          isLoading: state.status == CreateWallStatus.loading,
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
      ),
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
