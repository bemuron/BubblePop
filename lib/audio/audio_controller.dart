// File: lib/src/audio/audio_controller.dart
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../settings/settings.dart';
import 'sounds.dart';

/// Allows playing music and sound effects.
class AudioController extends ChangeNotifier {
  late AudioPlayer _musicPlayer;
  late AudioPlayer _sfxPlayer;

  SettingsController? _settings;
  ValueNotifier<AppLifecycleState>? _lifecycleNotifier;

  bool _musicEnabled = true;
  bool _soundsEnabled = true;

  /// Initialize the audio controller
  Future<void> initialize() async {
    _musicPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
  }

  void attachSettings(SettingsController settingsController) {
    _settings?.removeListener(_settingsListener);
    _settings = settingsController;
    _settings!.addListener(_settingsListener);
    _settingsListener();
  }

  void attachLifecycleNotifier(ValueNotifier<AppLifecycleState> lifecycleNotifier) {
    _lifecycleNotifier?.removeListener(_lifecycleListener);
    _lifecycleNotifier = lifecycleNotifier;
    _lifecycleNotifier!.addListener(_lifecycleListener);
  }

  void dispose() {
    _lifecycleNotifier?.removeListener(_lifecycleListener);
    _settings?.removeListener(_settingsListener);
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  /// Play a sound effect
  void playSfx(SfxType type) {
    if (!_soundsEnabled) return;

    final filename = soundTypeToFilename(type);
    if (filename.isNotEmpty) {
      try {
        _sfxPlayer.play(AssetSource('audio/${filename.first}'));
      } catch (e) {
        if (kDebugMode) {
          print('Error playing sound effect: $e');
        }
      }
    }
  }

  /// Start playing background music
  void playMusic() {
    if (!_musicEnabled) return;
    try {
      _musicPlayer.play(AssetSource('audio/background_music.mp3'));
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing music: $e');
      }
    }
  }

  /// Stop background music
  void stopMusic() {
    _musicPlayer.stop();
  }

  void _settingsListener() {
    if (_settings == null) return;

    _musicEnabled = _settings!.musicOn;
    _soundsEnabled = _settings!.soundsOn;

    if (!_musicEnabled) {
      stopMusic();
    }
  }

  void _lifecycleListener() {
    final state = _lifecycleNotifier?.value;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      stopMusic();
    } else if (state == AppLifecycleState.resumed && _musicEnabled) {
      playMusic();
    }
  }
}