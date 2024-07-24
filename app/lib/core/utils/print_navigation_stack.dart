import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void printNavigationStack(BuildContext context) {
  final router = GoRouter.of(context);
  final RouteMatchList matchList = router.routerDelegate.currentConfiguration;

  if (kDebugMode) {
    print('Current Navigation Stack:');
  }
  for (int i = 0; i < matchList.matches.length; i++) {
    final match = matchList.matches[i];
    if (kDebugMode) {
      print('${i + 1}. ${match.matchedLocation}');
    }
  }
}
