import 'package:bubble_pop/play_session/bubble_pop_flame.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../components/bubble.dart';
import '../../play_session/components/freeze_bubble.dart';

// An effect to freeze all bubbles on the screen.
class FreezeEffect extends Component with HasGameRef<BubblePopFlameGame> {
  static const double freezeDuration = 3.0; // seconds
  final List<Bubble> frozenBubbles = [];
  final Map<Bubble, ColorEffect> freezeOverlays = {}; // Track overlays for removal

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Small delay to ensure the freeze bubble has time to start its pop animation
    await Future.delayed(const Duration(milliseconds: 50));

    // Find all bubbles except FreezeBubbles and freeze them
    // Also exclude bubbles that are already popped
    final bubbles = gameRef.children.query<Bubble>().where((bubble) {
      return bubble is! FreezeBubble && !bubble.isPopped; // Exclude freeze bubbles and popped bubbles
    }).toList();

    for (final bubble in bubbles) {
      frozenBubbles.add(bubble);
      bubble.isFrozen = true;

      // Create and add freeze visual effect
      /*final freezeOverlay = ColorEffect(
         Color(0x88ADD8E6), // Light blue overlay for freeze effect
        EffectController(duration: 0.2),
      );*/

      // Store reference to the overlay for later removal
      //freezeOverlays[bubble] = freezeOverlay;
      //bubble.add(freezeOverlay);
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
        bubble.isFrozen = false;

        // Remove the specific freeze overlay we added
        /*final overlay = freezeOverlays[bubble];
        if (overlay != null && overlay.isMounted) {
          overlay.removeFromParent();
        }*/

        // Add a fade-out effect to show unfreezing
        /*bubble.add(ColorEffect(
          const Color(0x00FFFFFF), // Transparent
          EffectController(duration: 0.3),
        ));*/
      }
    }

    // Clear the lists
    frozenBubbles.clear();
    freezeOverlays.clear();
  }

  @override
  void onRemove() {
    // Safety: ensure all bubbles are unfrozen if component is removed early
    _unfreezeAllBubbles();
    super.onRemove();
  }
}