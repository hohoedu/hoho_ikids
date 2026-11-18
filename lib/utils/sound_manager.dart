import 'package:just_audio/just_audio.dart';

class SoundManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _correctPlayer = AudioPlayer();
  static final AudioPlayer _noPlayer = AudioPlayer();
  static final AudioPlayer _findSound = AudioPlayer();
  static final AudioPlayer _voicePlayer = AudioPlayer(); // 문장 읽기·정답 음성
  static final AudioPlayer _popPlayer = AudioPlayer(); // 하니팡 블록 터짐
  static final AudioPlayer _coinPlayer = AudioPlayer(); // 하니런 동전
  // 하니런 실패: 오답 동전 / 바위 / 쓰레기통
  static final Map<String, AudioPlayer> _runFailPlayers = {
    for (final n in ['run_fail', 'run_fail_rock', 'run_fail_trash']) n: AudioPlayer(),
  };
  static final AudioPlayer _sandPlayer = AudioPlayer(); // 유물 긁는 동안 반복 (Pixabay sand step 95801을 끊김 없게 가공)
  static final AudioPlayer _sparklePlayer = AudioPlayer(); // 유물 덮개 사라짐
  static final List<AudioPlayer> _comboPlayers = List.generate(4, (_) => AudioPlayer()); // 하니팡 콤보 1~4단계

  static Future<void> setupSounds() async {
    try {
      await _clickPlayer.setAsset('assets/audio/effect/click.mp3');
      await _correctPlayer.setAsset('assets/audio/effect/correct.mp3');
      await _noPlayer.setAsset('assets/audio/effect/no.mp3');
      await _findSound.setAsset('assets/audio/effect/find_explain.mp3');
      await _popPlayer.setAsset('assets/audio/effect/pang_pop.wav');
      await _coinPlayer.setAsset('assets/audio/effect/run_coin.wav');
      for (final e in _runFailPlayers.entries) {
        await e.value.setAsset('assets/audio/effect/${e.key}.wav'); // mp3 원본을 키운 버전
      }
      await _sandPlayer.setAsset('assets/audio/effect/relics_sand.wav');
      await _sandPlayer.setLoopMode(LoopMode.one);
      await _sparklePlayer.setAsset('assets/audio/effect/relics_sparkle.wav');
      for (var i = 0; i < _comboPlayers.length; i++) {
        await _comboPlayers[i].setAsset('assets/audio/effect/pang_combo${i + 1}.wav');
      }
    } catch (e) {
      print('사운드 로딩 오류: $e');
    }
    _warmUp(); // 기다리지 않음: 앱 시작을 늦추지 않게
  }

  /// 안드로이드는 플레이어마다 첫 재생 때 오디오 출력 준비가 늦어서 짧은 효과음이 통째로 묻힘.
  /// 시작할 때 소리 없이 한 번씩 재생해 두면 처음부터 들림.
  static Future<void> _warmUp() async {
    final players = [
      _clickPlayer, _correctPlayer, _noPlayer, _findSound, _popPlayer, _coinPlayer, _sandPlayer, _sparklePlayer,
      ..._runFailPlayers.values, ..._comboPlayers,
    ].where((p) => p.audioSource != null).toList();
    try {
      for (final p in players) {
        await p.setVolume(0);
        p.play();
      }
      await Future.delayed(const Duration(milliseconds: 500));
      for (final p in players) {
        await p.pause();
        await p.seek(Duration.zero);
        await p.setVolume(1);
      }
    } catch (e) {
      print('사운드 준비 오류: $e');
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

  /// 손가락으로 긁는 동안만 모래 소리 반복
  static Future<void> startSand() async {
    try {
      if (!_sandPlayer.playing) await _sandPlayer.play();
    } catch (e) {
      print("sand 재생 오류: $e");
    }
  }

  static Future<void> stopSand() async {
    try {
      await _sandPlayer.pause();
    } catch (_) {}
  }

  static Future<void> playSparkle() async {
    try {
      await _sparklePlayer.seek(Duration.zero);
      await _sparklePlayer.play();
    } catch (e) {
      print("sparkle 재생 오류: $e");
    }
  }

  /// [name]: run_fail(오답 동전), run_fail_rock(바위), run_fail_trash(쓰레기통)
  static Future<void> playRunFail(String name) async {
    final player = _runFailPlayers[name];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      print("$name 재생 오류: $e");
    }
  }

  static Future<void> playCoin() async {
    try {
      await _coinPlayer.seek(Duration.zero);
      await _coinPlayer.play();
    } catch (e) {
      print("coin 재생 오류: $e");
    }
  }

  static Future<void> playPop() async {
    try {
      await _popPlayer.seek(Duration.zero);
      await _popPlayer.play();
    } catch (e) {
      print("pop 재생 오류: $e");
    }
  }

  /// 콤보 [combo]번째(1부터). 높을수록 음이 올라가고 4단계부터는 같은 소리
  static Future<void> playCombo(int combo) async {
    final player = _comboPlayers[(combo - 1).clamp(0, _comboPlayers.length - 1)];
    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      print("combo 재생 오류: $e");
    }
  }

  /// 콘텐츠 음성 재생: 앱 에셋(assets/audio/voice/...) 또는 서버 URL(http...). 앞 음성은 끊고 새로 읽음.
  /// 파일이 아직 없으면 소리 없이 넘어감.
  static Future<void> playVoice(String asset) async {
    try {
      asset.startsWith('http') ? await _voicePlayer.setUrl(asset) : await _voicePlayer.setAsset(asset);
      await _voicePlayer.play();
    } catch (e) {
      print("voice 재생 오류($asset): $e");
    }
  }

  static Future<void> stopVoice() async {
    try {
      await _voicePlayer.stop();
    } catch (_) {}
  }

  static Future<void> setEffectVolume(double volume) async {
    await _clickPlayer.setVolume(volume);
    await _correctPlayer.setVolume(volume);
    await _noPlayer.setVolume(volume);
    await _findSound.setVolume(volume);
    await _voicePlayer.setVolume(volume);
    await _popPlayer.setVolume(volume);
    await _coinPlayer.setVolume(volume);
    for (final p in _runFailPlayers.values) {
      await p.setVolume(volume);
    }
    await _sandPlayer.setVolume(volume);
    await _sparklePlayer.setVolume(volume);
    for (final p in _comboPlayers) {
      await p.setVolume(volume);
    }
  }

  static Future<void> dispose() async {
    await _clickPlayer.dispose();
    await _correctPlayer.dispose();
    await _noPlayer.dispose();
    await _findSound.dispose();
    await _voicePlayer.dispose();
    await _popPlayer.dispose();
    await _coinPlayer.dispose();
    for (final p in _runFailPlayers.values) {
      await p.dispose();
    }
    await _sandPlayer.dispose();
    await _sparklePlayer.dispose();
    for (final p in _comboPlayers) {
      await p.dispose();
    }
  }
}