import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:app/features/feed/presentation/bloc/wall_feed/wall_feed_bloc.dart';
import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:app/features/feed/presentation/widgets/wall_feed_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final PagingController<int, Feed> _pagingController = PagingController(
    firstPageKey: 1,
    // invisibleItemsThreshold will determine how many items should be loaded
    // after the first page is loaded (if the first page does not fill the
    // screen, items enough to fill the page will be loaded anyway unless
    // invisibleItemsThreshold is set to 0).
    invisibleItemsThreshold: 1,
  );

  @override
  void initState() {
    super.initState();
    titleController.text = widget.wall.name;
    _pagingController.addPageRequestListener(
      (pageKey) {
        context.read<WallFeedBloc>().add(
              ListWallFeedsRequested(
                wallId: widget.wall.id,
                page: pageKey,
                pageSize: ServerConstants.defaultPaginationPageSize,
              ),
            );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    _pagingController.dispose();
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
    context.read<WallsBloc>().add(DeleteWallRequested(wallId: widget.wall.id));
  }

  Future<void> _updateWall() async {
    final newName = titleController.text.trim();

    if (formKey.currentState?.validate() == false) {
      return;
    }

    if (newName == widget.wall.name) {
      context.pop();
      return;
    }

    // Update wall with new name
    context.read<WallsBloc>().add(
          UpdateWallRequested(
            wallId: widget.wall.id,
            wallName: newName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WallsBloc, WallsState>(
      listener: (context, state) {
        if (state.status == WallStatus.success &&
            state.action == WallAction.delete) {
          showSnackbar(
            context,
            'Wall deleted',
            type: SnackbarType.info,
          );
          context.pop();
        } else if (state.status == WallStatus.failure &&
            state.action == WallAction.delete) {
          showSnackbar(
            context,
            state.message ?? 'Failed to delete wall',
            type: SnackbarType.failure,
          );
        } else if (state.status == WallStatus.success &&
            state.action == WallAction.update) {
          context.pop();
        } else if (state.status == WallStatus.failure &&
            state.action == WallAction.update) {
          showSnackbar(
            context,
            state.message ?? 'Failed to update wall',
            type: SnackbarType.failure,
          );
        }
      },
      builder: (context, state) {
        if (state.status == WallStatus.loading &&
            (state.action == WallAction.update ||
                state.action == WallAction.delete)) {
          return const Loader();
        }
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (!widget.wall.isPrimary)
                IconButton(
                  icon: const Icon(MingCute.delete_line),
                  onPressed: _deleteWall,
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
                const SizedBox(height: 40),
                Expanded(
                  child: Stack(
                    children: [
                      _createFeedListWidget(context),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: const [0.0, 0.4, 1],
                              colors: [
                                context.theme.colorScheme.surface,
                                context.theme.colorScheme.surface,
                                context.theme.colorScheme.surface.withAlpha(0),
                              ],
                            ),
                          ),
                          padding:
                              const EdgeInsets.only(bottom: 40.0, top: 20.0),
                          child: Button(
                            text: 'Done',
                            width: 120,
                            onPressed: () {
                              _updateWall();
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _createTitleEditWidget(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: context.theme.colorScheme.onSurface.withAlpha(191),
              ),
            ),
          ),
          child: TextFormField(
            style: context.theme.textTheme.headlineLarge!.copyWith(
              fontSize: titleController.text.length > 32 ? 24 : 28,
              fontWeight: FontWeight.w900,
            ),
            validator: _wallNameValidator,
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (_) {
              setState(() {
                isEditingTitle = true;
              });
            },
            onFieldSubmitted: (_) {
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
      ),
    );
  }

  Widget _createFeedListWidget(BuildContext context) {
    return BlocListener<WallFeedBloc, WallFeedState>(
      listener: (context, state) {
        if (state is WallFeedSuccess && state.action == WallFeedAction.list) {
          if (state.feedList!.metadata.currentPage ==
              state.feedList!.metadata.lastPage) {
            _pagingController.appendLastPage(state.feedList!.feeds);
          } else {
            final nextPage = state.feedList!.metadata.currentPage + 1;
            _pagingController.appendPage(state.feedList!.feeds, nextPage);
          }
        } else if (state is WallFeedFailure &&
            state.action == WallFeedAction.list) {
          _pagingController.error = state.message;
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: AppPagedList(
          pagingController: _pagingController,
          listType: PagedListType.list,
          itemBuilder: (context, item, index) => WallFeedListTile(
            feed: item,
            wallId: widget.wall.id,
            key: ValueKey(item.id),
            onRemove: () {
              final currentItems = _pagingController.itemList ?? [];
              final newItems = List<Feed>.from(currentItems)..removeAt(index);
              _pagingController.itemList = newItems;
            },
          ),
          firstPageErrorTitle: 'Error',
          newPageErrorTitle: 'Error',
          noMoreItemsErrorTitle: '',
          noMoreItemsErrorMessage: '',
          listEmptyErrorTitle: 'No feeds on this wall.',
          listEmptyErrorMessage: '',
        ),
      ),
    );
  }
}

String? _wallNameValidator(value) {
  if (value.isEmpty) {
    return 'Name cannot be empty';
  }

  if (value.length > 32) {
    return 'Maximum 32 characters allowed';
  }
  return null;
}
