import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../components/bubble.dart';
import '../main.dart';

// An effect to freeze all bubbles on the screen.
class FreezeEffect extends Component with HasGameRef<BubblePop> {
  static const double freezeDuration = 3.0; // seconds
  final List<Bubble> frozenBubbles = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Find all bubbles and freeze them
    final bubbles = gameRef.children.query<Bubble>();

    for (final bubble in bubbles) {
      frozenBubbles.add(bubble);
      bubble.isFrozen = true; // ← First line goes here (freeze bubbles)

      // Optional: Add visual effect to show bubble is frozen
      bubble.add(ColorEffect(
        const Color(0x88FFFFFF), // Semi-transparent white overlay
        EffectController(duration: 0.2),
      ));
    }

    // Create timer to unfreeze after duration
    add(TimerComponent(
      period: freezeDuration,
      repeat: false,
      onTick: () {
        _unfreezeAllBubbles();
        removeFromParent();
      },
    ));
  }

  void _unfreezeAllBubbles() {
    // Unfreeze all bubbles and remove visual effects
    for (final bubble in List.from(frozenBubbles)) {
      if (bubble.isMounted) { // Check if bubble still exists
        bubble.isFrozen = false; // ← Second line goes here (unfreeze bubbles)

        // Remove freeze visual effect
        bubble.add(ColorEffect(
          const Color(0x00FFFFFF), // Transparent
          EffectController(duration: 0.2),
        ));
      }
    }

    frozenBubbles.clear();
  }

  @override
  void onRemove() {
    // Safety: ensure all bubbles are unfrozen if component is removed early
    _unfreezeAllBubbles();
    super.onRemove();
  }
}