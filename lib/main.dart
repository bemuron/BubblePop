import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Correct import for TapCallbacks
import 'dart:math';

import 'components/bubble.dart';
import 'components/freeze_bubble.dart';
import 'components/stone.dart';
import 'effects/freeze_effect.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/main_menu.dart';

// The main entry point for the game.
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: GameWidget<BubblePop>.controlled(
        gameFactory: BubblePop.new,
      ),
    ),
  ));
}

// The main game class. It handles the game state and logic.
// Now using TapCallbacks, which is more appropriate for a tap-based game.
class BubblePop extends FlameGame with TapCallbacks {
  // Game state variables
  int score = 0;
  int stones = 0;
  bool isPlaying = false;
  final int maxStones = 10;
  final Random _random = Random();
  final TextPaint scoreTextPaint = TextPaint(
      style: const TextStyle( // Added const
        color: Colors.black, // Fixed: Use Colors.black instead of BasicPalette
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ));

  // Game components
  late TimerComponent _bubbleSpawner; // Changed from Timer to TimerComponent
  late TextComponent scoreDisplay;
  late TextComponent stonesDisplay;

  // The size of the game world.
  @override
  Color backgroundColor() => const Color(0xFF1D2021); // Sky blue background

  // Called once when the game starts.
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load assets and set up game components.
    // The background is a simple color, but you could load a sprite here.
    final background = SpriteComponent()
      ..sprite = await loadSprite('city_background.png')
      ..size = size
      ..anchor = Anchor.topLeft
      ..position = Vector2(0, 0);
    // Note: To use a custom background, you'd need to add it to your assets folder and uncomment this.
    // add(background);

    // Initialize the UI text components.
    scoreDisplay = TextComponent(
      text: 'Score: 0',
      textRenderer: scoreTextPaint,
      position: Vector2(10, 10),
    );
    add(scoreDisplay);

    stonesDisplay = TextComponent(
      text: 'Stones: 0/$maxStones',
      textRenderer: scoreTextPaint,
      position: Vector2(10, 40),
    );
    add(stonesDisplay);

    // Set up the bubble spawner timer - using TimerComponent instead of Timer
    _bubbleSpawner = TimerComponent(
      period: 1.5,
      onTick: _spawnBubble,
      repeat: true,
    );
    add(_bubbleSpawner); // Add the timer component to the game

    // Show the main menu initially.
    _showMainMenu();
  }

  // The main game loop - TimerComponent handles itself, no need to manually update
  @override
  void update(double dt) {
    super.update(dt);
    // TimerComponent updates automatically when added to the game
  }

  // Now using onTapDown, which is the correct method for tap events.
  @override
  bool onTapDown(TapDownEvent event) {
    if (!isPlaying) {
      _startGame();
    } else {
      // Find and handle taps on bubbles using the new query system
      final tappedBubbles = children.query<Bubble>().where((bubble) {
        // Use built-in hit detection instead of manual containsPoint
        return bubble.containsLocalPoint(event.localPosition);
      }).toList();

      for (var bubble in tappedBubbles) {
        // Handle freeze bubble power-up
        if (bubble is FreezeBubble) {
          add(FreezeEffect());
          bubble.onBubblePop();
        } else {
          score++;
          scoreDisplay.text = 'Score: $score';
          bubble.onBubblePop();
        }
      }
    }
    return true; // Return true to consume the event
  }

  // Spawns a new bubble.
  void _spawnBubble() {
    // Randomly choose between a regular bubble and a freeze bubble.
    final isFreezeBubble = _random.nextDouble() < 0.1; // 10% chance
    final bubble = isFreezeBubble ? FreezeBubble() : Bubble();
    bubble.x = _random.nextDouble() * (size.x - bubble.size.x);
    add(bubble);
  }

  // Game over state handler.
  void _gameOver() {
    isPlaying = false;
    _bubbleSpawner.timer.stop(); // Access the internal timer to stop it
    // Add the game over screen.
    add(GameOverMenu(onRestart: _restartGame));
  }

  // Starts the game.
  void _startGame() {
    // Clear the current children (bubbles, etc.) and reset state.
    children.query<MainMenu>().firstOrNull?.removeFromParent();
    _resetGameState();
    isPlaying = true;
    _bubbleSpawner.timer.start(); // Access the internal timer to start it
  }

  // Restarts the game.
  void _restartGame() {
    children.query<GameOverMenu>().firstOrNull?.removeFromParent();
    _resetGameState();
    isPlaying = true;
    _bubbleSpawner.timer.start(); // Access the internal timer to start it
  }

  // Resets all game state variables.
  void _resetGameState() {
    removeAll(children.query<Bubble>());
    removeAll(children.query<Stone>());
    score = 0;
    stones = 0;
    scoreDisplay.text = 'Score: $score';
    stonesDisplay.text = 'Stones: $stones/$maxStones';
  }

  // Shows the main menu overlay.
  void _showMainMenu() {
    add(MainMenu(onStart: _startGame));
  }

  // This method will be called by a Bubble when it transforms into a stone.
  void addStone() {
    stones++;
    stonesDisplay.text = 'Stones: $stones/$maxStones';
    if (stones >= maxStones) {
      _gameOver();
    }
  }
}