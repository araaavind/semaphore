import 'package:app/features/feed/presentation/widgets/topics_grid.dart';
import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/theme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore',
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
        child: TopicsGrid(onTap: (topic, color) {}),
      ),
    );
  }
}
