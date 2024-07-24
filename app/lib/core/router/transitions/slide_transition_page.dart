import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlideTransitionPage extends CustomTransitionPage<void> {
  SlideTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut))),
              child: child,
            );
          },
        );
}
