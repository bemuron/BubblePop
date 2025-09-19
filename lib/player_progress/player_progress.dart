// File: lib/src/player_progress/player_progress.dart
import 'dart:async';
import 'dart:convert';
import 'package:bubble_pop/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'package:bubble_pop/player_progress/persistence/player_progress_persistence.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encapsulates the player's progress.
class PlayerProgressController extends ChangeNotifier {
  static const _highScoreKey = 'bubble_pop_high_score';
  static const _gamesPlayedKey = 'bubble_pop_games_played';
  static const _totalBubblesPoppedKey = 'bubble_pop_total_bubbles';
  static const _highestLevelReachedKey = 'highest_level_reached';
  static const _starsForLevelKey = 'stars_for_level';

  /// By default, settings are persisted using
  /// [LocalStoragePlayerProgressPersistence] (i.e. NSUserDefaults on iOS,
  /// SharedPreferences on Android or local storage on the web).
  final PlayerProgressPersistence _store;

  SharedPreferences? _prefs;

  PlayerProgressController({PlayerProgressPersistence? store})
      : _store = store ?? LocalStoragePlayerProgressPersistence() {
    _getLatestFromStore();
  }

  int _highScore = 0;
  int _gamesPlayed = 0;
  int _totalBubblesPopped = 0;
  int _highestLevelReached = 0;
  final Map<int, int> _starsForLevel = {};

  /// The player's current high score.
  int get highScore => _highScore;

  /// Total number of games played.
  int get gamesPlayed => _gamesPlayed;

  /// Total bubbles popped across all games.
  int get totalBubblesPopped => _totalBubblesPopped;

  /// The highest level the player has reached.
  int get highestLevelReached => _highestLevelReached;

  /// Stars earned for each completed level.
  Map<int, int> get starsForLevel => _starsForLevel;

  /// Initialize the controller and load saved progress.
  /*Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
  }*/

  /// Fetches the latest data from the backing persistence store.
  Future<void> _getLatestFromStore() async {
    final level = await _store.getHighestLevelReached();
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();
    } else if (level < _highestLevelReached) {
      await _store.saveHighestLevelReached(_highestLevelReached);
    }
  }

  void setLevelReached(int level) {
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();

      unawaited(_store.saveHighestLevelReached(level));
    }
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

  /// Records a level as completed and updates the stars earned.
  Future<void> recordLevelCompletion(int level, {required int stars}) async {
    if (kDebugMode) {
      print('Recording level completion for level $level with $stars stars.');
    }

    if (_highestLevelReached < level) {
      _highestLevelReached = level;
      await _prefs?.setInt(_highestLevelReachedKey, _highestLevelReached);
    }
    _starsForLevel[level] = stars;
    await _saveStars();
    notifyListeners();
  }

  /// Reset all progress (for testing or user request).
  Future<void> reset() async {
    _highScore = 0;
    _gamesPlayed = 0;
    _totalBubblesPopped = 0;
    _highestLevelReached = 0;
    _starsForLevel.clear();

    await _prefs?.remove(_highScoreKey);
    await _prefs?.remove(_gamesPlayedKey);
    await _prefs?.remove(_totalBubblesPoppedKey);
    await _prefs?.remove(_highestLevelReachedKey);
    await _prefs?.remove(_starsForLevelKey);

    notifyListeners();
  }

  Future<void> _loadProgress() async {
    _highScore = _prefs?.getInt(_highScoreKey) ?? 0;
    _gamesPlayed = _prefs?.getInt(_gamesPlayedKey) ?? 0;
    _totalBubblesPopped = _prefs?.getInt(_totalBubblesPoppedKey) ?? 0;
    _highestLevelReached = _prefs?.getInt(_highestLevelReachedKey) ?? 0;

    // Corrected logic for loading stars.
    final starsJson = _prefs?.getString(_starsForLevelKey);
    _starsForLevel.clear(); // Clear the existing map before loading
    if (starsJson != null) {
      final Map<String, dynamic> decoded = json.decode(starsJson);
      decoded.forEach((key, value) {
        _starsForLevel[int.parse(key)] = value as int;
      });
    }

    notifyListeners();
  }

  Future<void> _saveStars() async {
    final Map<String, int> encoded =
    _starsForLevel.map((key, value) => MapEntry(key.toString(), value));
    await _prefs?.setString(_starsForLevelKey, json.encode(encoded));
  }
}