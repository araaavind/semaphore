import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/feed/domain/entities/wall.dart';
import 'package:flutter/material.dart';

class WallViewPage extends StatefulWidget {
  final Wall wall;
  const WallViewPage({
    required this.wall,
    super.key,
  });

  @override
  State<WallViewPage> createState() => _WallViewPageState();
}

class _WallViewPageState extends State<WallViewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wall.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit wall name functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Implement delete wall functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: UIConstants.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(),
            ),
            const SizedBox(height: 20.0),
            Button(
              text: 'Add Feed',
              backgroundColor: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
              onPressed: () {
                // Implement add feed to wall functionality
              },
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
