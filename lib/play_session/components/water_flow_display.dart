// File: lib/src/play_session/components/water_flow_display.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Visual component showing water flow percentage with animated water effect
class WaterFlowDisplay extends RectangleComponent {
  double _waterPercentage = 100.0;
  late Paint _waterPaint;
  late Paint _pipePaint;
  late Paint _backgroundPaint;
  final List<WaterDrop> _waterDrops = [];
  double _animationTime = 0.0;

  WaterFlowDisplay() : super(size: Vector2(60, 200)) {
    _waterPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    _pipePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    _backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    // Initialize water drops
    _initializeWaterDrops();
  }

  void _initializeWaterDrops() {
    _waterDrops.clear();
    for (int i = 0; i < 10; i++) {
      _waterDrops.add(WaterDrop(
        x: size.x * 0.3 + (math.Random().nextDouble() * size.x * 0.4),
        y: math.Random().nextDouble() * size.y,
        speed: 50 + math.Random().nextDouble() * 50,
      ));
    }
  }

  void updateWaterFlow(double percentage) {
    _waterPercentage = math.max(0.0, math.min(100.0, percentage));

    // Adjust number of visible drops based on flow
    final visibleDrops = (_waterPercentage / 100 * _waterDrops.length).floor();
    for (int i = 0; i < _waterDrops.length; i++) {
      _waterDrops[i].visible = i < visibleDrops;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animationTime += dt;

    // Update water drops
    for (final drop in _waterDrops) {
      if (drop.visible && _waterPercentage > 0) {
        drop.y += drop.speed * dt * (_waterPercentage / 100);

        // Reset drop when it goes off screen
        if (drop.y > size.y + 10) {
          drop.y = -10;
          drop.x = size.x * 0.3 + (math.Random().nextDouble() * size.x * 0.4);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw pipe background
    final pipeRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pipeRect, const Radius.circular(8)),
      _backgroundPaint,
    );

    // Draw water flow area
    if (_waterPercentage > 0) {
      final waterHeight = size.y * (_waterPercentage / 100);
      final waterRect = Rect.fromLTWH(
        5,
        size.y - waterHeight,
        size.x - 10,
        waterHeight,
      );

      // Gradient effect for water
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.cyan.withOpacity(0.6),
          Colors.blue.withOpacity(0.8),
        ],
      );

      final waterPaint = Paint()
        ..shader = gradient.createShader(waterRect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(waterRect, const Radius.circular(6)),
        waterPaint,
      );
    }

    // Draw water drops
    for (final drop in _waterDrops) {
      if (drop.visible && _waterPercentage > 0) {
        final dropPaint = Paint()
          ..color = Colors.cyan.withOpacity(0.8);

        canvas.drawCircle(
          Offset(drop.x, drop.y),
          3,
          dropPaint,
        );
      }
    }

    // Draw pipe outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(pipeRect, const Radius.circular(8)),
      _pipePaint,
    );

    // Draw percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${_waterPercentage.toInt()}%',
        style: TextStyle(
          color: _waterPercentage > 30 ? Colors.white : Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        size.y + 10,
      ),
    );
  }
}

class WaterDrop {
  double x;
  double y;
  final double speed;
  bool visible = true;

  WaterDrop({
    required this.x,
    required this.y,
    required this.speed,
  });
}