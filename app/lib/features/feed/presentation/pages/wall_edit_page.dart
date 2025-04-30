import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/feed/presentation/cubit/wall/wall_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WallEditPage extends StatefulWidget {
  final Wall wall;
  const WallEditPage({
    required this.wall,
    super.key,
  });

  @override
  State<WallEditPage> createState() => _WallEditPageState();
}

class _WallEditPageState extends State<WallEditPage> {
  final titleController = TextEditingController();
  bool isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.wall.name;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _deleteWall() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: const EdgeInsets.only(
              top: 36.0,
              left: 32.0,
              right: 24.0,
              bottom: 24.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            backgroundColor: context.theme.colorScheme.surface,
            content: Text.rich(
              TextSpan(
                style: context.theme.textTheme.bodyLarge,
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: widget.wall.name,
                    style: context.theme.textTheme.bodyLarge!.copyWith(
                      color: context.theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' wall ?'),
                  TextSpan(
                    text: '\n\n(This action cannot be undone.)',
                    style: context.theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: context.theme.textTheme.titleMedium!.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: context.theme.textTheme.titleMedium!.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    if (!mounted) return;

    // Proceed with deletion
    context.read<WallCubit>().deleteWall(widget.wall.id);
  }

  Future<void> _updateWall() async {
    final newName = titleController.text.trim();

    if (newName.isEmpty) {
      showSnackbar(
        context,
        'Name cannot be empty',
        type: SnackbarType.failure,
      );
      return;
    }

    if (newName.length > 32) {
      showSnackbar(
        context,
        'Name must be less than 32 characters long',
        type: SnackbarType.failure,
      );
      return;
    }

    if (newName == widget.wall.name) {
      context.pop();
      return;
    }

    // Update wall with new name
    context.read<WallCubit>().updateWall(
          widget.wall.id,
          newName,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallCubit, WallState>(listener: (context, state) {
      if (state.status == WallStatus.success &&
          state.action == WallAction.delete) {
        showSnackbar(
          context,
          'Wall deleted',
          type: SnackbarType.info,
        );

        // Select the primary wall to navigate back to
        final walls = context.read<WallsBloc>().state.walls;
        context.read<WallsBloc>().add(
              SelectWallRequested(
                selectedWall: walls.firstWhere((element) => element.isPrimary),
              ),
            );
        context.read<WallsBloc>().add(ListWallsRequested());
        context.goNamed(RouteConstants.wallPageName);
      } else if (state.status == WallStatus.failure &&
          state.action == WallAction.delete) {
        // Show error message
        showSnackbar(
          context,
          state.message ?? 'Failed to delete wall',
          type: SnackbarType.failure,
        );
      } else if (state.status == WallStatus.success &&
          state.action == WallAction.update) {
        // Handle successful update
        showSnackbar(
          context,
          'Wall name changed',
          type: SnackbarType.info,
        );

        // Refresh the wall list
        context.read<WallsBloc>().add(ListWallsRequested());
        context.pop();
      } else if (state.status == WallStatus.failure &&
          state.action == WallAction.update) {
        // Show error message for update failure
        showSnackbar(
          context,
          state.message ?? 'Failed to update wall',
          type: SnackbarType.failure,
        );
      }
    }, builder: (context, state) {
      if (state.status == WallStatus.loading &&
          (state.action == WallAction.update ||
              state.action == WallAction.delete)) {
        return const Loader();
      }
      return Scaffold(
        appBar: AppBar(
          actions: [
            if (!widget.wall.isPrimary) // Prevent deleting primary wall
              IconButton(
                icon: const Icon(
                  MingCute.delete_line,
                  color: Colors.red,
                ),
                onPressed: _deleteWall,
              ),
            IconButton(
              icon: const Icon(MingCute.check_line),
              onPressed: _updateWall,
            ),
          ],
        ),
        body: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _createTitleEditWidget(context),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Button(
                  text: 'Add Feed',
                  onPressed: () {
                    // Implement add feed to wall functionality
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _createTitleEditWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: context.theme.colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ),
        child: TextField(
          style: context.theme.textTheme.headlineLarge!.copyWith(
            fontSize: titleController.text.length > 32 ? 24 : 28,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 3,
          minLines: 1,
          textAlign: TextAlign.center,
          controller: titleController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {
              isEditingTitle = true;
            });
          },
          onSubmitted: (_) {
            setState(() {
              isEditingTitle = false;
            });
            FocusScope.of(context).unfocus();
          },
          onTapOutside: (_) {
            setState(() {
              isEditingTitle = false;
            });
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}
