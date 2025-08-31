// File: lib/src/audio/sounds.dart
List<String> soundTypeToFilename(SfxType type) {
  switch (type) {
    case SfxType.buttonTap:
      return ['tap1.mp3', 'tap2.mp3'];
    case SfxType.victory:
      return ['victory.mp3'];
    case SfxType.gameOver:
      return ['gameover.mp3'];
    case SfxType.powerUp:
      return ['powerup.mp3'];
  }
}

/// Allows control over loudness of different SFX types.
double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.victory:
      return 0.4;
    case SfxType.gameOver:
      return 0.2;
    case SfxType.buttonTap:
    case SfxType.powerUp:
      return 1.0;
  }
}

enum SfxType {
  buttonTap,
  victory,
  gameOver,
  powerUp,
}