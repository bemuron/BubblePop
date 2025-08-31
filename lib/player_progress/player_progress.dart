// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'persistence/local_storage_player_progress_persistence.dart';
import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  static const maxHighestScoresPerPlayer = 10;
  static const _highScoreKey = 'bubble_pop_high_score';
  static const _gamesPlayedKey = 'bubble_pop_games_played';
  static const _totalBubblesPoppedKey = 'bubble_pop_total_bubbles';

  SharedPreferences? _prefs;

  /// By default, settings are persisted using
  /// [LocalStoragePlayerProgressPersistence] (i.e. NSUserDefaults on iOS,
  /// SharedPreferences on Android or local storage on the web).
  //final PlayerProgressPersistence _store;

  int _highestLevelReached = 0;
  int _highScore = 0;
  int _gamesPlayed = 0;
  int _totalBubblesPopped = 0;

  /// The player's current high score.
  int get highScore => _highScore;

  /// Total number of games played.
  int get gamesPlayed => _gamesPlayed;

  /// Total bubbles popped across all games.
  int get totalBubblesPopped => _totalBubblesPopped;

  /// The highest level that the player has reached so far.
  int get highestLevelReached => _highestLevelReached;

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

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  /// Reset all progress (for testing or user request).
  Future<void> reset() async {
    _highScore = 0;
    _gamesPlayed = 0;
    _totalBubblesPopped = 0;
    _highestLevelReached = 0;

    //_store.saveHighestLevelReached(_highestLevelReached);
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

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  /*PlayerProgress({PlayerProgressPersistence? store})
      : _store = store ?? LocalStoragePlayerProgressPersistence() {
    _getLatestFromStore();
  }*/

  /// Registers [level] as reached.
  ///
  /// If this is higher than [highestLevelReached], it will update that
  /// value and save it to the injected persistence store.
  /*void setLevelReached(int level) {
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();

      unawaited(_store.saveHighestLevelReached(level));
    }
  }*/

  /// Fetches the latest data from the backing persistence store.
  /*Future<void> _getLatestFromStore() async {
    final level = await _store.getHighestLevelReached();
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();
    } else if (level < _highestLevelReached) {
      await _store.saveHighestLevelReached(_highestLevelReached);
    }
  }*/
}
