// File: lib/src/settings/settings.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An class that holds settings like [playerName] or [musicOn],
/// and saves them to an injected persistence store.
class SettingsController extends ChangeNotifier {
  static const _playerNameKey = 'playerName';
  static const _soundsOnKey = 'soundsOn';
  static const _musicOnKey = 'musicOn';

  SharedPreferences? _prefs;

  String _playerName = 'Player';
  bool _soundsOn = true;
  bool _musicOn = true;

  String get playerName => _playerName;
  bool get soundsOn => _soundsOn;
  bool get musicOn => _musicOn;

  /// Initialize the controller and load saved settings.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> setPlayerName(String name) async {
    _playerName = name;
    await _prefs?.setString(_playerNameKey, name);
    notifyListeners();
  }

  Future<void> toggleSounds() async {
    _soundsOn = !_soundsOn;
    await _prefs?.setBool(_soundsOnKey, _soundsOn);
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicOn = !_musicOn;
    await _prefs?.setBool(_musicOnKey, _musicOn);
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _playerName = _prefs?.getString(_playerNameKey) ?? 'Player';
    _soundsOn = _prefs?.getBool(_soundsOnKey) ?? true;
    _musicOn = _prefs?.getBool(_musicOnKey) ?? true;
    notifyListeners();
  }
}