import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BgmController extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  final Map<String, String> _bgmTracks = {
    'write': 'assets/audio/bgm/write.mp3',
    'intro': 'assets/audio/effect/intro.mp3',
    'hani': 'assets/audio/bgm/hani_main.mp3',
    'puzzle': 'assets/audio/bgm/puzzle.mp3',
    'find_diff': 'assets/audio/bgm/find_diff.mp3',
    'match': 'assets/audio/bgm/match.mp3',
    'flip': 'assets/audio/bgm/flip.mp3',
    'clean': 'assets/audio/bgm/clean.mp3',
    'quiz': 'assets/audio/bgm/quiz.mp3',
    'word': 'assets/audio/bgm/word.mp3',
    'jaram': 'assets/audio/bgm/booki_j_main.mp3',
    'kium': 'assets/audio/bgm/booki_k_main.mp3',
    'mannam': 'assets/audio/bgm/booki_d_main.mp3',
    'kidok': 'assets/audio/bgm/kidok.mp3',
  };

  String _currentTrack = '';

  @override
  void onInit() {
    super.onInit();
    preloadBgm();
  }

  Future<void> preloadBgm() async {
    for (var track in _bgmTracks.values) {
      await _player.setAsset(track);
    }
  }

  Future<void> playBgm(String screen) async {
    if (!_bgmTracks.containsKey(screen)) return;
    String newTrack = _bgmTracks[screen]!;

    if (_currentTrack == newTrack) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    _currentTrack = newTrack;
    await _player.setAsset(newTrack);
    _player.setLoopMode(LoopMode.one);
    _player.play();
  }

  void stopBgm() {
    _player.pause();
    _player.seek(Duration.zero);
  }

  void pauseBgm() {
    _player.pause();
  }

  void resumeBgm() {
    _player.play();
  }

  void setBgmVolume(double volume) {
    _player.setVolume(volume);
  }
}
