import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fondo decorativo: degradado de naranja de marca a negro, con pequeñas
/// bolas blancas y negras cayendo despacio en bucle. Pensado solo para
/// pantallas estáticas (la de inicio): la animación es barata (un puñado
/// de círculos repintados con un solo AnimationController), pero no tiene
/// sentido pagarla en el mapa o la navegación, donde ya hay mucho más
/// repintándose por segundo.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  late final List<_Particle> _particles =
      List.generate(28, (i) => _Particle.random(Random(i * 7919)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.seedColor,
                Color(0xFFC2501C),
                Color(0xFF8A3414),
                Color(0xFF55200D),
                Color(0xFF2B1007),
                Color(0xFF120603),
                Colors.black,
              ],
              stops: [0.0, 0.16, 0.34, 0.52, 0.7, 0.86, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _FallingParticlesPainter(_particles, _controller.value),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.phase,
    required this.speed,
    required this.radius,
    required this.isWhite,
    required this.opacity,
  });

  /// Posición horizontal, de 0 a 1 (proporción del ancho).
  final double x;

  /// Desfase inicial de 0 a 1, para que no caigan todas a la vez.
  final double phase;

  /// Multiplicador de velocidad relativo (algunas caen más rápido que otras).
  final double speed;
  final double radius;
  final bool isWhite;
  final double opacity;

  factory _Particle.random(Random r) => _Particle(
        x: r.nextDouble(),
        phase: r.nextDouble(),
        speed: 0.4 + r.nextDouble() * 1.1,
        radius: 2 + r.nextDouble() * 5,
        isWhite: r.nextBool(),
        opacity: 0.12 + r.nextDouble() * 0.3,
      );

  double _progressAt(double t) => (phase + t * speed) % 1.0;
}

class _FallingParticlesPainter extends CustomPainter {
  _FallingParticlesPainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final progress = particle._progressAt(t);
      final y = progress * (size.height + 60) - 30;
      final x = particle.x * size.width;
      final paint = Paint()
        ..color = (particle.isWhite ? Colors.white : Colors.black)
            .withValues(alpha: particle.opacity);
      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FallingParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}
