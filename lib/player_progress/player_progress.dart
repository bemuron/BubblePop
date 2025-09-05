// File: lib/src/player_progress/player_progress.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encapsulates the player's progress.
class PlayerProgressController extends ChangeNotifier {
  static const _highScoreKey = 'bubble_pop_high_score';
  static const _gamesPlayedKey = 'bubble_pop_games_played';
  static const _totalBubblesPoppedKey = 'bubble_pop_total_bubbles';

  SharedPreferences? _prefs;

  int _highScore = 0;
  int _gamesPlayed = 0;
  int _totalBubblesPopped = 0;

  /// The player's current high score.
  int get highScore => _highScore;

  /// Total number of games played.
  int get gamesPlayed => _gamesPlayed;

  /// Total bubbles popped across all games.
  int get totalBubblesPopped => _totalBubblesPopped;

  /// Initialize the controller and load saved progress.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
  }

  /// Updates the high score if the provided score is higher.
  Future<void> setHighScore(int score) async {
    if (score <= _highScore) return;

    _highScore = score;
    await _prefs?.setInt(_highScoreKey, _highScore);
    notifyListeners();
  }

  /// Records that a game was completed.
  Future<void> recordGamePlayed() async {
    _gamesPlayed++;
    await _prefs?.setInt(_gamesPlayedKey, _gamesPlayed);
    notifyListeners();
  }

  /// Records bubbles popped in the current game.
  Future<void> recordBubblesPopped(int bubblesPopped) async {
    _totalBubblesPopped += bubblesPopped;
    await _prefs?.setInt(_totalBubblesPoppedKey, _totalBubblesPopped);
    notifyListeners();
  }

  /// Reset all progress (for testing or user request).
  Future<void> reset() async {
    _highScore = 0;
    _gamesPlayed = 0;
    _totalBubblesPopped = 0;

    await _prefs?.remove(_highScoreKey);
    await _prefs?.remove(_gamesPlayedKey);
    await _prefs?.remove(_totalBubblesPoppedKey);

    notifyListeners();
  }

  Future<void> _loadProgress() async {
    _highScore = _prefs?.getInt(_highScoreKey) ?? 0;
    _gamesPlayed = _prefs?.getInt(_gamesPlayedKey) ?? 0;
    _totalBubblesPopped = _prefs?.getInt(_totalBubblesPoppedKey) ?? 0;

    notifyListeners();
  }
}