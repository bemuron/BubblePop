// File: lib/play_session/components/freeze_indicator.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FreezeIndicator extends RectangleComponent {
  int _freezeCount = 0;
  late Paint _backgroundPaint;
  late Paint _iconPaint;
  late Paint _borderPaint;
  final List<FreezeBubbleIcon> _bubbleIcons = [];

  FreezeIndicator() : super(size: Vector2(120, 40)) {
    _backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _iconPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;

    // Initialize bubble icons
    for (int i = 0; i < 4; i++) {
      _bubbleIcons.add(FreezeBubbleIcon(
        x: 15 + (i * 25),
        y: 20,
      ));
    }
  }

  void updateFreezeCount(int count) {
    _freezeCount = math.max(0, math.min(4, count));

    // Update icon visibility
    for (int i = 0; i < _bubbleIcons.length; i++) {
      _bubbleIcons[i].active = i < _freezeCount;
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      _backgroundPaint,
    );

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      _borderPaint,
    );

    // Draw freeze bubble icons
    for (final icon in _bubbleIcons) {
      icon.render(canvas);
    }

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'FREEZE',
        style: TextStyle(
          color: _freezeCount > 0 ? Colors.lightBlueAccent : Colors.grey,
          fontSize: 12,
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
        2,
      ),
    );
  }
}

class FreezeBubbleIcon {
  final double x;
  final double y;
  bool active = false;
  double _glowAnimation = 0.0;

  FreezeBubbleIcon({required this.x, required this.y});

  void update(double dt) {
    if (active) {
      _glowAnimation += dt * 2;
    }
  }

  void render(Canvas canvas) {
    final radius = 8.0;
    final center = Offset(x, y);

    if (active) {
      // Draw glowing effect
      final glowIntensity = (math.sin(_glowAnimation) + 1) / 2;
      final glowPaint = Paint()
        ..color = Colors.lightBlueAccent.withOpacity(0.3 + glowIntensity * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, glowPaint);

      // Draw active freeze bubble
      final activePaint = Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, activePaint);

      // Draw highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x - 2, y - 2), radius * 0.3, highlightPaint);
    } else {
      // Draw inactive freeze bubble
      final inactivePaint = Paint()
        ..color = Colors.grey[600]!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, inactivePaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.grey[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(center, radius, borderPaint);
    }
  }
}