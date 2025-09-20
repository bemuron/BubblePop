// File: lib/src/audio/audio_controller.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'sounds.dart';

/// Allows playing music and sound effects.
class AudioController extends ChangeNotifier {
  late AudioPlayer _musicPlayer;
  late AudioPlayer _sfxPlayer;

  bool _musicEnabled = true;
  bool _soundsEnabled = true;
  bool _audioPreloaded = false;
  bool _musicLoaded = false;

  // Cache for preloaded sound effects
  final Map<SfxType, bool> _preloadedSounds = {};

  bool get musicEnabled => _musicEnabled;
  bool get soundsEnabled => _soundsEnabled;
  bool get audioReady => _audioPreloaded;

  /// Initialize the audio controller
  Future<void> initialize() async {
    _musicPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    // Preload audio assets
    await _preloadAudio();
  }

  /// Preload critical audio assets
  Future<void> _preloadAudio() async {
    if (_audioPreloaded) return;

    try {
      print('Preloading audio assets...');

      // Preload common sound effects
      final commonSounds = [SfxType.buttonTap, SfxType.gameOver, SfxType.victory];

      for (final sfxType in commonSounds) {
        try {
          final filenames = soundTypeToFilename(sfxType);
          if (filenames.isNotEmpty) {
            // Test load the sound with timeout
            await _sfxPlayer.setSourceAsset('sfx/${filenames.first}')
                .timeout(const Duration(seconds: 2));
            _preloadedSounds[sfxType] = true;
          }
        } catch (e) {
          print('Failed to preload ${sfxType.name}: $e');
          _preloadedSounds[sfxType] = false;
        }
      }

      // Preload background music
      try {
        await _musicPlayer.setSourceAsset('music/bubbles_Oleksii_Kalyna_pixabay.mp3')
            .timeout(const Duration(seconds: 3));
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        _musicLoaded = true;
        print('Background music preloaded successfully');
      } catch (e) {
        print('Failed to preload background music: $e');
        _musicLoaded = false;
      }

      _audioPreloaded = true;
      print('Audio preloading completed');

    } catch (e) {
      print('Audio preload failed: $e');
      _audioPreloaded = false;
    }
  }

  /// Update settings (call this when settings change)
  void updateSettings({required bool musicOn, required bool soundsOn}) {
    _musicEnabled = musicOn;
    _soundsEnabled = soundsOn;

    if (!_musicEnabled) {
      stopMusic();
    } else {
      playMusic();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  /// Play a sound effect with error handling and timeout
  void playSfx(SfxType type) {
    if (!_soundsEnabled || !_audioPreloaded) return;

    // Check if this sound was successfully preloaded
    if (_preloadedSounds[type] == false) return;

    final filenames = soundTypeToFilename(type);
    if (filenames.isEmpty) return;

    // Fire and forget - don't block the game thread
    _playSfxAsync(filenames.first).catchError((e) {
      if (kDebugMode) {
        print('Error playing sound effect ${type.name}: $e');
      }
    });
  }

  /// Async sound effect playback with timeout
  Future<void> _playSfxAsync(String filename) async {
    try {
      await _sfxPlayer.play(AssetSource('sfx/$filename'))
          .timeout(const Duration(seconds: 1));
    } on TimeoutException {
      if (kDebugMode) {
        print('Sound effect timeout - skipping');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  /// Start playing background music with error handling
  void playMusic() {
    if (!_musicEnabled || !_musicLoaded) return;

    // Fire and forget - don't block the game thread
    _playMusicAsync().catchError((e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    });
  }

  /// Async music playback with timeout
  Future<void> _playMusicAsync() async {
    try {
      await _musicPlayer.resume().timeout(const Duration(seconds: 2));
    } on TimeoutException {
      if (kDebugMode) {
        print('Background music timeout - continuing without music');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Background music error: $e');
      }
    }
  }

  /// Stop background music
  void stopMusic() {
    try {
      _musicPlayer.pause();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping music: $e');
      }
    }
  }

  /// Retry audio initialization if it failed
  Future<void> retryAudioInit() async {
    _audioPreloaded = false;
    _musicLoaded = false;
    _preloadedSounds.clear();
    await _preloadAudio();
    notifyListeners();
  }
}