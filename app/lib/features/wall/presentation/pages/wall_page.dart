import 'package:app/features/wall/presentation/widgets/wall_page_sliver_app_bar.dart';
import 'package:flutter/material.dart';

class WallPage extends StatelessWidget {
  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          WallPageSliverAppBar(),
          WallPageSliverList(),
        ],
      ),
    );
  }
}

class WallPageSliverList extends StatelessWidget {
  const WallPageSliverList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const Text('Nothing to see yet');
        },
        childCount: 1,
      ),
    );
  }
}
