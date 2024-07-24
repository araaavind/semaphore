import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  final String? message;
  const ErrorPage({
    this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message ?? 'Something went wrong',
              style: context.theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                context.goNamed(RouteConstants.wallPageName);
              },
              child: Text(
                'Home',
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
