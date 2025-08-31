
// File: lib/src/audio/audio_controller.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'sounds.dart';

/// Allows playing music and sound effects.
class AudioController extends ChangeNotifier {
  late AudioPlayer _musicPlayer;
  late AudioPlayer _sfxPlayer;

  bool _musicEnabled = true;
  bool _soundsEnabled = true;

  bool get musicEnabled => _musicEnabled;
  bool get soundsEnabled => _soundsEnabled;

  /// Initialize the audio controller
  Future<void> initialize() async {
    _musicPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
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

  /// Play a sound effect
  void playSfx(SfxType type) {
    if (!_soundsEnabled) return;

    final filenames = soundTypeToFilename(type);
    if (filenames.isNotEmpty) {
      try {
        _sfxPlayer.play(AssetSource('sfx/${filenames.first}'));
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
      _musicPlayer.play(AssetSource('music/Mr_Smith-Sunday_Solitude.mp3'));
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
}