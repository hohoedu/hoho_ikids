import 'package:just_audio/just_audio.dart';

class SoundManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _correctPlayer = AudioPlayer();
  static final AudioPlayer _noPlayer = AudioPlayer();
  static final AudioPlayer _findSound = AudioPlayer();

  static Future<void> setupSounds() async {
    try {
      await _clickPlayer.setAsset('assets/audio/effect/click.mp3');
      await _correctPlayer.setAsset('assets/audio/effect/correct.mp3');
      await _noPlayer.setAsset('assets/audio/effect/no.mp3');
      await _findSound.setAsset('assets/audio/effect/find_explain.mp3');
    } catch (e) {
      print('사운드 로딩 오류: $e');
    }
  }

  static Future<void> playClick() async {
    try {
      await _clickPlayer.seek(Duration.zero);
      await _clickPlayer.play();
    } catch (e) {
      print("click 재생 오류: $e");
    }
  }

  static Future<void> playCorrect() async {
    try {
      await _correctPlayer.seek(Duration.zero);
      await _correctPlayer.play();
    } catch (e) {
      print("correct 재생 오류: $e");
    }
  }

  static Future<void> playNo() async {
    try {
      await _noPlayer.seek(Duration.zero);
      await _noPlayer.play();
    } catch (e) {
      print("no 재생 오류: $e");
    }
  }

  static Future<void> playFind() async {
    try {
      await _findSound.seek(Duration.zero);
      await _findSound.setLoopMode(LoopMode.off);
      await _findSound.play();
    } catch (e) {
      print("find 재생 오류: $e");
    }
  }

  static Future<void> setEffectVolume(double volume) async {
    await _clickPlayer.setVolume(volume);
    await _correctPlayer.setVolume(volume);
    await _noPlayer.setVolume(volume);
    await _findSound.setVolume(volume);
  }

  static Future<void> dispose() async {
    await _clickPlayer.dispose();
    await _correctPlayer.dispose();
    await _noPlayer.dispose();
    await _findSound.dispose();
  }
}