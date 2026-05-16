import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SplashParticlesWidget extends StatefulWidget {
  const SplashParticlesWidget({super.key});

  @override
  State<SplashParticlesWidget> createState() => _SplashParticlesWidgetState();
}

class _SplashParticlesWidgetState extends State<SplashParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _particles = List.generate(55, (_) => _Particle(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double opacity;
  late double phase;
  late Color color;

  _Particle(math.Random rnd) {
    x = rnd.nextDouble();
    y = rnd.nextDouble();
    radius = rnd.nextDouble() * 2.5 + 0.8;
    speed = rnd.nextDouble() * 0.12 + 0.04;
    opacity = rnd.nextDouble() * 0.5 + 0.1;
    phase = rnd.nextDouble() * math.pi * 2;
    color = rnd.nextBool() ? AppTheme.primary : AppTheme.primaryMagenta;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y - p.speed * progress) % 1.0;
      final wobbleX = p.x + math.sin(progress * math.pi * 2 + p.phase) * 0.02;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(wobbleX * size.width, currentY * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
