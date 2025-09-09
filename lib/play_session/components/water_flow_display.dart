// File: lib/src/play_session/components/water_flow_bar.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterFlowBar extends RectangleComponent {
  double _percentage = 100.0;
  late Paint _backgroundPaint;
  late Paint _waterPaint;
  late Paint _borderPaint;

  WaterFlowBar() : super(size: Vector2(150, 20)) {
    _backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _updateWaterPaint();
  }

  void updatePercentage(double percentage) {
    _percentage = math.max(0.0, math.min(100.0, percentage));
    _updateWaterPaint();
  }

  void _updateWaterPaint() {
    Color waterColor;
    if (_percentage > 60) {
      waterColor = Colors.blue;
    } else if (_percentage > 30) {
      waterColor = Colors.orange;
    } else {
      waterColor = Colors.red;
    }

    _waterPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      _backgroundPaint,
    );

    // Draw water
    if (_percentage > 0) {
      final waterWidth = size.x * (_percentage / 100);
      final waterRect = Rect.fromLTWH(0, 0, waterWidth, size.y);
      canvas.drawRRect(
        RRect.fromRectAndRadius(waterRect, const Radius.circular(4)),
        _waterPaint,
      );
    }

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      _borderPaint,
    );
  }
}