// File: lib/src/game_internals/level_state.dart
import 'package:flutter/foundation.dart';
import 'dart:math';

enum BubbleSize { normal, medium, large }

class LevelConfig {
  final int levelNumber;
  final int initialStones;
  final Map<BubbleSize, double> bubbleSizeDistribution;
  final int freezeBubbles;
  final double waterFlowSensitivity;
  final String goal;
  final Duration? timeLimit;
  final int? targetBubbles;
  final double? minimumWaterFlow;

  LevelConfig({
    required this.levelNumber,
    required this.initialStones,
    required this.bubbleSizeDistribution,
    required this.freezeBubbles,
    required this.waterFlowSensitivity,
    required this.goal,
    this.timeLimit,
    this.targetBubbles,
    this.minimumWaterFlow,
  });

  static LevelConfig getLevel(int level) {
    switch (level) {
      case 1:
        return LevelConfig(
          levelNumber: 1,
          initialStones: 0,
          bubbleSizeDistribution: {BubbleSize.normal: 1.0},
          freezeBubbles: 4,
          waterFlowSensitivity: 0.5, // Slow decrease
          goal: 'Pop 50 bubbles before water drops below 50%',
          targetBubbles: 50,
          minimumWaterFlow: 50.0,
        );
      case 2:
        return LevelConfig(
          levelNumber: 2,
          initialStones: 2,
          bubbleSizeDistribution: {
            BubbleSize.normal: 0.7,
            BubbleSize.medium: 0.3,
          },
          freezeBubbles: 3,
          waterFlowSensitivity: 1.0,
          goal: 'Maintain water flow above 30% for 90 seconds',
          timeLimit: Duration(seconds: 90),
          minimumWaterFlow: 30.0,
        );
      case 3:
        return LevelConfig(
          levelNumber: 3,
          initialStones: 4,
          bubbleSizeDistribution: {
            BubbleSize.normal: 0.5,
            BubbleSize.medium: 0.3,
            BubbleSize.large: 0.2,
          },
          freezeBubbles: 2,
          waterFlowSensitivity: 1.5,
          goal: 'Pop 100 bubbles and keep water flow above 20%',
          targetBubbles: 100,
          minimumWaterFlow: 20.0,
        );
      case 4:
        return LevelConfig(
          levelNumber: 4,
          initialStones: 6,
          bubbleSizeDistribution: {
            BubbleSize.normal: 0.4,
            BubbleSize.medium: 0.4,
            BubbleSize.large: 0.2,
          },
          freezeBubbles: 1,
          waterFlowSensitivity: 2.0,
          goal: 'Survive 2 minutes without water flow hitting 0%',
          timeLimit: Duration(seconds: 120),
          minimumWaterFlow: 0.1,
        );
      default: // Level 5+: Endless mode
        return LevelConfig(
          levelNumber: level,
          initialStones: 4 + (level - 5),
          bubbleSizeDistribution: {
            BubbleSize.normal: 0.3,
            BubbleSize.medium: 0.4,
            BubbleSize.large: 0.3,
          },
          freezeBubbles: max(1, 3 - (level - 5) ~/ 2),
          waterFlowSensitivity: 1.0 + (level - 5) * 0.2,
          goal: 'Endless survival - achieve high score',
        );
    }
  }
}

/// Enhanced game state with water flow and levels
class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  final VoidCallback onLose;

  LevelState({
    required this.onWin,
    required this.onLose,
  });

  int _currentLevel = 1;
  LevelConfig? _levelConfig;

  int _score = 0;
  int _stones = 0;
  int _bubblesPopped = 0;
  int _freezeBubblesRemaining = 0;
  double _waterFlowPercentage = 100.0;
  bool _isGameOver = false;
  DateTime? _levelStartTime;

  // Getters
  int get currentLevel => _currentLevel;
  LevelConfig? get levelConfig => _levelConfig;
  int get score => _score;
  int get stones => _stones;
  int get bubblesPopped => _bubblesPopped;
  int get freezeBubblesRemaining => _freezeBubblesRemaining;
  double get waterFlowPercentage => _waterFlowPercentage;
  bool get isGameOver => _isGameOver;

  Duration? get timeRemaining {
    if (_levelConfig?.timeLimit == null || _levelStartTime == null) return null;
    final elapsed = DateTime.now().difference(_levelStartTime!);
    final remaining = _levelConfig!.timeLimit! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void startLevel(int level) {
    _currentLevel = level;
    _levelConfig = LevelConfig.getLevel(level);
    _levelStartTime = DateTime.now();

    _score = 0;
    _stones = _levelConfig!.initialStones;
    _bubblesPopped = 0;
    _freezeBubblesRemaining = _levelConfig!.freezeBubbles;
    _waterFlowPercentage = 100.0;
    _isGameOver = false;

    notifyListeners();
  }

  void incrementScore([int points = 10]) {
    _score += points;
    _bubblesPopped += 1;
    _checkWinConditions();
    notifyListeners();
  }

  void addStones(int count) {
    _stones += count;
    _updateWaterFlow();
    _checkGameOver();
    notifyListeners();
  }

  void useFreezeEffect() {
    if (_freezeBubblesRemaining > 0) {
      _freezeBubblesRemaining--;
      notifyListeners();
    }
  }

  void _updateWaterFlow() {
    if (_levelConfig == null) return;

    // Calculate water flow based on stones and level sensitivity
    final stoneImpact = _stones * _levelConfig!.waterFlowSensitivity;
    _waterFlowPercentage = max(0.0, 100.0 - stoneImpact * 5.0);

    // Additional penalties for different bubble sizes that became stones
    // This is approximated - in practice you'd track which size bubbles became stones
  }

  void setGameOver({required bool won}) {
    if (_isGameOver) return;

    _isGameOver = true;

    if (won) {
      onWin();
    } else {
      onLose();
    }

    notifyListeners();
  }

  void _checkWinConditions() {
    if (_levelConfig == null || _isGameOver) return;

    bool won = false;

    // Check target bubbles
    if (_levelConfig!.targetBubbles != null &&
        _bubblesPopped >= _levelConfig!.targetBubbles!) {
      won = true;
    }

    // Check time limit survival
    if (_levelConfig!.timeLimit != null && timeRemaining == Duration.zero) {
      if (_levelConfig!.minimumWaterFlow == null ||
          _waterFlowPercentage > _levelConfig!.minimumWaterFlow!) {
        won = true;
      }
    }

    if (won) {
      _isGameOver = true;
      onWin();
    }
  }

  void _checkGameOver() {
    if (_isGameOver) return;

    // Game over if water flow hits minimum threshold
    if (_levelConfig?.minimumWaterFlow != null &&
        _waterFlowPercentage <= _levelConfig!.minimumWaterFlow!) {
      _isGameOver = true;
      onLose();
      return;
    }

    // Game over if water flow hits 0%
    if (_waterFlowPercentage <= 0.0) {
      _isGameOver = true;
      onLose();
    }
  }

  void update(double dt) {
    if (_isGameOver || _levelConfig == null) return;

    // Check time-based win/lose conditions
    if (_levelConfig!.timeLimit != null) {
      final remaining = timeRemaining;
      if (remaining == Duration.zero) {
        if (_levelConfig!.minimumWaterFlow != null &&
            _waterFlowPercentage <= _levelConfig!.minimumWaterFlow!) {
          _isGameOver = true;
          onLose();
        } else if (_levelConfig!.targetBubbles == null) {
          // Time-based survival level completed
          _isGameOver = true;
          onWin();
        }
        notifyListeners();
      }
    }
  }

  void reset() {
    if (_levelConfig != null) {
      startLevel(_currentLevel); // Restart current level
    }
  }

  void nextLevel() {
    startLevel(_currentLevel + 1);
  }

  BubbleSize getRandomBubbleSize() {
    if (_levelConfig == null) return BubbleSize.normal;

    final random = Random();
    double chance = random.nextDouble();
    double cumulative = 0.0;

    for (final entry in _levelConfig!.bubbleSizeDistribution.entries) {
      cumulative += entry.value;
      if (chance <= cumulative) {
        return entry.key;
      }
    }

    return BubbleSize.normal; // Fallback
  }

  // Static methods for bubble properties
  static int getTapsRequired(BubbleSize size) {
    switch (size) {
      case BubbleSize.normal:
        return 1;
      case BubbleSize.medium:
        return 2;
      case BubbleSize.large:
        return 4;
    }
  }

  static int getStonesCreated(BubbleSize size) {
    switch (size) {
      case BubbleSize.normal:
        return 1;
      case BubbleSize.medium:
        return 2;
      case BubbleSize.large:
        return 4;
    }
  }

  static double getBubbleScale(BubbleSize size) {
    switch (size) {
      case BubbleSize.normal:
        return 1.0;
      case BubbleSize.medium:
        return 1.4;
      case BubbleSize.large:
        return 1.8;
    }
  }
}