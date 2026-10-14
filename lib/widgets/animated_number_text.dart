import 'package:flutter/material.dart';

/// Texto que anima suavemente desde su valor numérico anterior hasta el
/// nuevo cuando [value] cambia, en vez de refrescarse de golpe. En el
/// primer build anima desde 0, a modo de pequeña entrada.
class AnimatedNumberText extends StatelessWidget {
  const AnimatedNumberText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => Text(
        formatter(animatedValue),
        style: style,
      ),
    );
  }
}
