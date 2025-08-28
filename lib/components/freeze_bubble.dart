import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

import 'bubble.dart';
import '../main.dart';

// Represents the Freeze Bubble power-up.
class FreezeBubble extends Bubble {
  static final _freezePaint = BasicPalette.cyan.paint()
    ..filterQuality = FilterQuality.high;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Use a different color or sprite to distinguish it.
    sprite = await gameRef.loadSprite('bubble_2.png');
    paint = _freezePaint;
  }
}