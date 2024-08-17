import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WallPage extends StatelessWidget {
  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'smphr',
          style: context.theme.textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.theme.colorScheme.secondary,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Nothing to see here yet')],
        ),
      ),
    );
  }
}
