// File: lib/src/style/confetti.dart
import 'package:flutter/material.dart';
import 'dart:math';

/// A simple confetti widget for celebrations
class Confetti extends StatefulWidget {
  const Confetti({
    super.key,
    required this.isStopped,
  });

  final bool isStopped;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(_random));
    }

    if (!widget.isStopped) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(Confetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStopped && !oldWidget.isStopped) {
      _controller.stop();
    } else if (!widget.isStopped && oldWidget.isStopped) {
      _controller.repeat();
    }
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
          painter: ConfettiPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;

  ConfettiParticle(Random random) {
    x = random.nextDouble();
    y = -0.1;
    vx = (random.nextDouble() - 0.5) * 0.5;
    vy = random.nextDouble() * 0.3 + 0.2;
    color = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ][random.nextInt(6)];
    size = random.nextDouble() * 8 + 4;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 10;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;

  ConfettiPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = (particle.x + particle.vx * animationValue) * size.width;
      final y = (particle.y + particle.vy * animationValue) * size.height;

      if (y > size.height) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * animationValue);

      final paint = Paint()..color = particle.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-particle.size / 2, -particle.size / 2,
              particle.size, particle.size),
          Radius.circular(particle.size / 4),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}