import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedViewPage extends StatelessWidget {
  final Feed feed;
  const FeedViewPage({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  feed.title,
                  style: context.theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 5,
                  minFontSize: context.theme.textTheme.titleLarge!.fontSize!,
                ),
                const SizedBox(height: 20.0),
                Text(
                  feed.description ?? '',
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12.0),
                if (feed.pubUpdated != null)
                  Text(
                    'Last published at ${DateFormat('d MMM, yyyy').format(feed.pubUpdated!)}',
                    style: context.theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w100,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
