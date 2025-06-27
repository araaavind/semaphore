import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final Widget icon;
  final EdgeInsets padding;
  final VoidCallback onPressed;
  final Duration duration;
  final bool animateOnTap;
  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.padding,
    required this.onPressed,
    this.duration = const Duration(milliseconds: 300),
    this.animateOnTap = true,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final double _scaleTo = 1.2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create a sequence animation that:
    // 1. Expands to _scaleTo (0-30% of animation)
    // 2. Contracts to 0.9x (30-60% of animation)
    // 3. Returns to 1.0x with bounce (60-100% of animation)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: _scaleTo)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _scaleTo, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playAnimation() {
    // Reset to start and play the full animation
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.animateOnTap) {
          _playAnimation();
        }
        widget.onPressed();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: widget.padding,
          child: widget.icon,
        ),
      ),
    );
  }
}
