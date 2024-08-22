import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum SlideDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }

class SlideTransitionPage extends CustomTransitionPage<void> {
  final SlideDirection direction;

  SlideTransitionPage({
    required LocalKey super.key,
    required super.child,
    required this.direction,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset beginOffset;
            switch (direction) {
              case SlideDirection.leftToRight:
                beginOffset = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.rightToLeft:
                beginOffset = const Offset(1.0, 0.0);
                break;
              case SlideDirection.topToBottom:
                beginOffset = const Offset(0.0, -1.0);
                break;
              case SlideDirection.bottomToTop:
                beginOffset = const Offset(0.0, 1.0);
                break;
            }

            return SlideTransition(
              position: animation.drive(Tween(
                begin: beginOffset,
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut))),
              child: child,
            );
          },
        );
}
