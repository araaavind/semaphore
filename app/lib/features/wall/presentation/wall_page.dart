import 'package:app/core/constants/constants.dart';
import 'package:flutter/material.dart';

class WallPage extends StatelessWidget {
  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Nothing to see here')],
        ),
      ),
    );
  }
}
