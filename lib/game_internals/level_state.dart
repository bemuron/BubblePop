// File: lib/src/game_internals/level_state.dart
import 'package:flutter/foundation.dart';

/// An extremely simple representation of game state.
class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  final VoidCallback onLose;

  LevelState({
    required this.onWin,
    required this.onLose,
  });

  int _score = 0;
  int _stones = 0;
  int _bubblesPopped = 0;
  bool _isGameOver = false;

  int get score => _score;
  int get stones => _stones;
  int get bubblesPopped => _bubblesPopped;
  bool get isGameOver => _isGameOver;

  void incrementScore() {
    _score += 1;
    _bubblesPopped += 1;
    notifyListeners();
  }

  void addStone() {
    _stones += 1;
    notifyListeners();
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

  void reset() {
    _score = 0;
    _stones = 0;
    _bubblesPopped = 0;
    _isGameOver = false;
    notifyListeners();
  }
}