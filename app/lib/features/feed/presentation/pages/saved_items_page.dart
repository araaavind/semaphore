import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/features/feed/presentation/widgets/saved_item_paged_list.dart';
import 'package:flutter/material.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          children: [
            const SizedBox(width: 4),
            const Icon(MingCute.bookmarks_line, size: 22),
            const SizedBox(width: 8),
            Text(
              'Saved Articles',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(UIConstants.pagePadding),
        child: SavedItemPagedList(),
      ),
    );
  }
}
