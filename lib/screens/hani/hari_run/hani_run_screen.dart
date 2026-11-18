import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_data.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_logic.dart';
import 'package:get/get.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/score_summary.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

/// 하니런: 말풍선의 훈음에 맞는 한자 동전이 있는 길로 달려가 받는다. 돌·쓰레기통은 피한다.
class HaniRunScreen extends StatefulWidget {
  const HaniRunScreen({super.key, required this.keyCode, this.pool, this.random, this.obstacles = true});

  /// 첫 글자(Y·S…)로 동전 세트를 고름
  final String keyCode;

  /// 서버에서 받은 동전 한자 목록. 없으면 키코드 과정의 임시 목록(runHanjaFor)
  final List<Hanja>? pool;

  /// 테스트에서 문제·장애물을 고정할 때만 넘김
  final Random? random;
  final bool obstacles;

  @override
  State<HaniRunScreen> createState() => _HaniRunScreenState();
}

enum _Kind { coin, rock, trash }

/// 길 위를 왼쪽으로 지나가는 것 하나 (동전/장애물)
class _Thing {
  _Thing(this.kind, this.lane, this.x, [this.hanja]);

  final _Kind kind;
  final int lane; // 0 위, 1 아래
  final Hanja? hanja;
  double x; // 화면 왼쪽부터의 중심 위치(px)
  bool done = false; // 채점·충돌 처리 끝
  bool caught = false; // 캐릭터가 받음/부딪힘
}

class _HaniRunScreenState extends State<HaniRunScreen> with TickerProviderStateMixin {
  static const _dir = 'assets/images/hani/run';
  static const _bgAspect = 2160 / 724;

  // run_bg.png 세로 비율: 위 차선 중심, 가운데 점선, 아래 차선 중심
  static const _laneY = [0.4755, 0.6955];
  static const _dashY = 0.585;

  static const _baseTravel = 4.0; // 처음엔 화면 오른쪽에서 캐릭터까지 4초
  static const _firstCalmQuestions = 2; // 처음 몇 문제는 장애물 없음
  // 장애물은 문제와 상관없이 따로 나옴: 화면에 한 개씩, 1.2~3초마다 아무 차선에
  static const _obstacleMinSec = 1.2;
  static const _obstacleMaxSec = 3.0;
  static const _clearSec = 2.5; // 장애물과 동전 사이 최소 간격(차선 바꿀 시간)
  // 로티 길이에 맞춤: Hoho_hanihit.json 3초, Hoho_hanirunheart.json 1초
  static const _hitSec = 3.0; // 부딪힘·오답 모션(이 동안 길이 멈춤)
  static const _heartSec = 1.0; // 정답 모션

  late final Random _rand = widget.random ?? Random();
  late final List<Hanja> _pool = widget.pool ?? runHanjaFor(widget.keyCode);
  late final Ticker _ticker = createTicker(_tick);
  // 시작 전 안내: true면 시각 데모, false면 텍스트 안내(지금은 텍스트)
  static const _visualGuide = false;
  // 시작 전 시각 안내 데모 한 바퀴(손가락 톡 → 하니 위로 → 동전 ✓)
  late final AnimationController _demo =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
        ..addListener(() => setState(() {}));
  Duration _last = Duration.zero;

  late HanjaRun _run;
  late HanjaQuiz _quiz;
  HanjaQuestion? _question;
  final _things = <_Thing>[];
  double _nextSpawnIn = 1.0;
  double _nextObstacleIn = 0;
  int _lane = 0;
  double _bgOffset = 0;
  double _hurtUntil = 0;
  double _hitUntil = 0; // 하니 부딪힘 모션 끝나는 시각
  double _heartUntil = 0; // 하니 정답 모션 끝나는 시각
  double? _heartLostAt; // 하트 -1 이 하늘로 날아가기 시작한 시각
  double _time = 0;
  ({String text, Color color, double at})? _toast;
  bool _over = false;
  bool _started = false; // 하는 방법 안내 → 1, 2, 3, 시작! 뒤에 달리기 시작
  bool _counting = false; // 시작하기 누른 뒤(안내 닫힘)
  String? _countdown;

  Size _size = Size.zero;
  double _charX = 0;

  @visibleForTesting
  HanjaRun get run => _run;
  @visibleForTesting
  HanjaQuestion? get question => _question;

  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().playBgm('hani_run'); // 나가면 하니 홈이 didPopNext에서 하니 BGM으로 돌림
    _restart();
    if (_visualGuide) _demo.repeat();
  }

  /// 시작하기: 안내를 닫고 카운트다운
  void _start() {
    if (_counting) return;
    _counting = true;
    _demo.stop();
    _countdownThenRun();
  }

  /// 1, 2, 3, 시작! 을 보여 준 뒤 달리기 시작(처음·다시하기 공통)
  Future<void> _countdownThenRun() async {
    _started = false;
    _ticker.stop();
    for (final label in const ['1', '2', '3', '시작!']) {
      setState(() => _countdown = label);
      if (label == '시작!') {
        _started = true;
        _ticker.start();
      }
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
    }
    setState(() => _countdown = null);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _demo.dispose();
    super.dispose();
  }

  void _restart() {
    _run = HanjaRun();
    _quiz = HanjaQuiz(pool: _pool, random: _rand);
    _question = null;
    _things.clear();
    _nextSpawnIn = 1.0;
    _nextObstacleIn = _obstacleMaxSec;
    _lane = 0;
    _toast = null;
    _hitUntil = _heartUntil = 0;
    _heartLostAt = null;
    _over = false;
  }

  /// 화면 너비가 달라도 같은 시간에 도착하도록 px/초로 환산
  double get _speed => (_size.width - _charX) / _baseTravel * (_run.fallSpeed / HanjaRun.baseSpeed);

  double get _coinSize => _size.height * 0.21;

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = now;
    if (_size == Size.zero) return;
    _time += dt;

    // 부딪히면 hit 모션 동안 길·물건이 멈춤
    if (!_over && _time >= _hitUntil) {
      final move = _speed * dt;
      _bgOffset += move;
      for (final t in _things) {
        t.x -= move;
      }
      _things.removeWhere((t) => t.x < -_coinSize * 2);

      if (_question == null && !_run.isOver) {
        _nextSpawnIn -= dt;
        if (_nextSpawnIn <= 0) _spawn();
      }
      if (widget.obstacles && !_run.isOver && _quiz.asked > _firstCalmQuestions) {
        _nextObstacleIn -= dt;
        if (_nextObstacleIn <= 0) _spawnObstacle();
      }
      _checkHits();
    }
    setState(() {});
  }

  void _spawn() {
    final q = _quiz.next();
    _question = q;
    var x = _size.width + _coinSize;
    // 바로 앞에 장애물이 있으면 피한 뒤 고를 시간만큼 동전을 뒤로 미룸
    final clear = _speed * _clearSec;
    for (final t in _things.where((t) => t.kind != _Kind.coin)) {
      if ((t.x - x).abs() < clear) x = t.x + clear;
    }
    for (final side in Side.values) {
      _things.add(_Thing(_Kind.coin, side == Side.left ? 0 : 1, x, q.at(side)));
    }
  }

  void _spawnObstacle() {
    _nextObstacleIn = _obstacleMinSec + _rand.nextDouble() * (_obstacleMaxSec - _obstacleMinSec);
    final x = _size.width + _coinSize;
    if (_things.any((t) => t.kind != _Kind.coin)) return; // 화면에 장애물은 한 개만
    // 동전과 겹치면 이번엔 건너뜀(시간 기준이라 빨라져도 같은 여유)
    if (_things.any((t) => t.kind == _Kind.coin && (t.x - x).abs() < _speed * _clearSec)) return;
    _things.add(_Thing(_rand.nextBool() ? _Kind.rock : _Kind.trash, _rand.nextInt(2), x));
  }

  void _checkHits() {
    for (final t in _things.where((t) => !t.done && t.x <= _charX)) {
      if (t.kind != _Kind.coin) {
        t.done = true;
        if (t.lane == _lane) {
          t.caught = true;
          _run.onCrash();
          _hurt(t.kind == _Kind.rock ? 'run_fail_rock' : 'run_fail_trash', '아야!');
          _afterMistake();
        }
        continue;
      }
      // 동전 두 개는 같은 x로 오므로 한 번에 채점
      final q = _question;
      if (q == null) continue;
      final pair = _things.where((c) => c.kind == _Kind.coin && !c.done).toList();
      for (final c in pair) {
        c.done = true;
      }
      final got = pair.firstWhere((c) => c.lane == _lane);
      got.caught = true;
      if (identical(got.hanja, q.target)) {
        SoundManager.playCoin(); // 정답 동전 먹는 소리
        final gained = _run.onCorrect();
        _toast = (text: '+$gained', color: const Color(0xFFFF8A1F), at: _time);
        _heartUntil = _time + _heartSec;
        _hitUntil = 0;
      } else {
        _run.onMistake(q.target);
        _quiz.markMistake(q.target);
        _hurt('run_fail'); // 오답 동전
      }
      _question = null;
      _nextSpawnIn = 0.6;
      _afterMistake();
      return;
    }
  }

  void _hurt(String sound, [String? text]) {
    SoundManager.playRunFail(sound);
    _hurtUntil = _time + 0.7;
    _hitUntil = _time + _hitSec;
    _heartUntil = 0;
    _heartLostAt = _time;
    if (text != null) _toast = (text: text, color: const Color(0xFFE53935), at: _time);
  }

  void _afterMistake() {
    if (_run.isOver && !_over) {
      // 마지막 부딪힘 모션(3초)을 다 보여 준 뒤 점수 화면
      Future.delayed(Duration(milliseconds: (_hitSec * 1000).round()), () async {
        if (!mounted) return;
        setState(() => _over = true);
        // 점수·별 먼저 보여 주고, 부키 콘텐츠와 같은 결과 다이얼로그
        await showScoreSummary(score: _run.score, stars: _run.stars);
        if (!mounted) return;
        lottieDialog(
          stars: _run.stars,
          onReset: () {
            Get.back();
            setState(_restart);
            _countdownThenRun();
          },
          onMain: () {
            Get.back();
            Get.back();
          },
        );
      });
    }
  }

  void _setLane(int lane) {
    if (!_started || _over || _run.isOver) return;
    _lane = lane;
  }

  // ───────── 화면 ─────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MainAppBar(isContent: false, title: ''),
      body: LayoutBuilder(
        builder: (context, c) {
          final safe = MediaQuery.paddingOf(context);
          final side = max(16.0, max(safe.left, safe.right));
          _size = c.biggest;
          final h = _size.height;
          _charX = max(side + h * 0.12, _size.width * 0.16);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _setLane(d.localPosition.dy < h * _dashY ? 0 : 1),
            onVerticalDragUpdate: (d) {
              if (d.delta.dy.abs() > 2) _setLane(d.delta.dy < 0 ? 0 : 1);
            },
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                ..._buildBackground(),
                for (final t in _things) _buildThing(t),
                _buildCharacter(),
                _buildBubble(),
                _buildToast(),
                _buildLostHeart(),
                Positioned(top: h * 0.03, right: side, height: h * 0.11, child: _buildHud(h * 0.11)),
                if (!_counting) _visualGuide ? _buildVisualGuide() : _buildGuide(),
                if (_countdown != null) _buildCountdown(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBackground() {
    final h = _size.height, bgW = h * _bgAspect;
    final o = _bgOffset % bgW;
    return [
      // 같은 그림 두 장을 이어 붙여 왼쪽으로 흘려보냄
      for (final left in [-o, bgW - o])
        Positioned(
          left: left,
          top: 0,
          width: bgW + 1, // 이음새 틈 방지
          height: h,
          child: Image.asset('$_dir/run_bg.png', fit: BoxFit.fill),
        ),
    ];
  }

  Widget _buildThing(_Thing t) {
    final h = _size.height;
    final cy = h * _laneY[t.lane];
    final Size size = switch (t.kind) {
      _Kind.coin => Size.square(_coinSize),
      _Kind.rock => Size(h * 0.16 * 306 / 167, h * 0.16),
      _Kind.trash => Size(h * 0.22 * 284 / 220, h * 0.22),
    };
    // 장애물은 길 위에 놓인 느낌이 나게 바닥을 차선 아래쪽에 맞춤
    final top = t.kind == _Kind.coin ? cy - size.height / 2 : cy + h * 0.08 - size.height;

    Widget child = switch (t.kind) {
      _Kind.coin => _coin(t.hanja!),
      _Kind.rock => Image.asset('$_dir/rock.png'),
      _Kind.trash => Image.asset('$_dir/trash.png'),
    };

    if (t.done && t.kind == _Kind.coin) {
      // 받은 동전은 위로 떠오르며, 안 받은 동전은 그 자리에서 사라짐
      child = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        builder: (context, v, child) => Opacity(
          opacity: 1 - v,
          child: Transform.translate(
            offset: Offset(0, t.caught ? -v * size.height * 0.6 : 0),
            child: Transform.scale(scale: t.caught ? 1 + v * 0.3 : 1 - v * 0.4, child: child),
          ),
        ),
        child: child,
      );
    }

    return Positioned(
      key: ObjectKey(t),
      left: t.x - size.width / 2,
      top: top,
      width: size.width,
      height: size.height,
      child: child,
    );
  }

  /// 한자가 박힌 동전 이미지 (coin-y01.png 등)
  Widget _coin(Hanja hanja) => Image.asset('$_dir/coin-${hanja.no}.png');

  Widget _buildCharacter() {
    final h = _size.height;
    final ch = h * 0.30, cw = ch; // 하니 로티 3종 모두 900x900
    final hurt = _time < _hurtUntil;
    // 게임 끝 > 오답·장애물 > 정답 > 평상시 달리기
    final motion = _run.isOver || _time < _hitUntil
        ? 'hanihit'
        : _time < _heartUntil
            ? 'hanirunheart'
            : 'hanirun';
    return AnimatedPositioned(
      key: const ValueKey('character'),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      left: _charX - cw / 2,
      top: h * _laneY[_counting || !_visualGuide ? _lane : _demoLane] - ch * 0.6,
      width: cw,
      height: ch,
      child: Opacity(
        // 부딪히면 깜빡임
        opacity: hurt && (_time * 10).floor().isEven ? 0.35 : 1,
        // 키가 바뀌면 모션이 처음부터 재생됨
        // 부딪히는게 3초, 정답 1초
        // 시작 전엔 첫 프레임에 멈춰 있고, 끝나면 부딪힘 모션을 한 번만 하고 마지막 자세로 멈춤
        child: Lottie.asset(
          'assets/lottie/Hoho_$motion.json',
          key: ValueKey(motion),
          fit: BoxFit.contain,
          animate: _started,
          repeat: !_run.isOver,
        ),
      ),
    );
  }

  Widget _buildBubble() {
    // 시작 전엔 안내 데모 문제(불 화)
    final reading = _counting || !_visualGuide ? _question?.target.text : _pool.first.text;
    final h = _size.height;
    final bw = h * 0.37, bh = bw * 232 / 425;
    return Positioned(
      key: const ValueKey('bubble'),
      left: _charX + h * 0.09,
      top: h * 0.11,
      width: bw,
      height: bh,
      child: AnimatedOpacity(
        opacity: reading == null ? 0 : 1,
        duration: const Duration(milliseconds: 150),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('$_dir/blank.png'),
            // 구름 몸통(꼬리·반짝이 빼고) 가운데
            Align(
              alignment: const Alignment(-0.08, -0.12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: bw * 0.12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(reading ?? '', style: _text(bh * 0.32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToast() {
    final t = _toast;
    if (t == null || _time - t.at > 1.2) return const SizedBox.shrink(); 
    final h = _size.height, v = (_time - t.at) / 1.2;
    return Positioned(
      left: _charX + h * 0.15,
      top: h * _laneY[_lane] - h * 0.12 - v * h * 0.08,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - v).clamp(0, 1),
          child: Text(
            t.text,
            style: _text(h * 0.07).copyWith(
              color: t.color,
              shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
            ),
          ),
        ),
      ),
    );
  }

  /// 하트를 잃으면 하니 머리 위에서 하트 -1 이 하늘로 날아감
  Widget _buildLostHeart() {
    final at = _heartLostAt;
    if (at == null || _time - at > 1.2) return const SizedBox.shrink();
    final h = _size.height, v = (_time - at) / 1.2;
    final startY = h * _laneY[_lane] - h * 0.3;
    return Positioned(
      left: _charX - h * 0.08 + sin(v * pi * 3) * h * 0.03, // 살랑살랑
      top: startY - Curves.easeIn.transform(v) * (startY + h * 0.15),
      child: IgnorePointer(
        child: Opacity(
          opacity: (1.4 - v).clamp(0, 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('$_dir/heart.png', height: h * 0.09),
              Text(
                ' -1',
                style: _text(h * 0.07).copyWith(
                  color: const Color(0xFFE53935),
                  shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 데모에서 손가락이 위 길을 누른 뒤(절반 지점) 하니가 위로 감
  int get _demoLane => _demo.value < 0.45 ? 1 : 0;

  /// 시작 전 시각 안내: 실제 길 위에서 정답 동전 길을 누르는 모습을 반복해 보여 줌
  Widget _buildVisualGuide() {
    final w = _size.width, h = _size.height, v = _demo.value;
    final coinX = _charX + (w - _charX) * 0.42, s = _coinSize;
    final tapX = w * 0.72, tapY = h * _laneY[0];
    // 0.30~0.45 손가락 내려가며 누름, 0.45~0.70 물결 퍼짐, 0.55~ 정답 동전 ✓
    final press = ((v - 0.30) / 0.15).clamp(0.0, 1.0);
    final ripple = ((v - 0.45) / 0.25).clamp(0.0, 1.0);
    final check = Curves.easeOutBack.transform(((v - 0.55) / 0.15).clamp(0.0, 1.0));

    Widget coin(int lane, Hanja hanja, {required bool right}) => Positioned(
          left: coinX - s / 2,
          top: h * _laneY[lane] - s / 2,
          width: s,
          height: s,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Opacity(opacity: right || check == 0 ? 1 : 1 - check * 0.6, child: _coin(hanja)),
              if (right && check > 0)
                Positioned(
                  right: -s * 0.1,
                  top: -s * 0.1,
                  child: Transform.scale(
                    scale: check,
                    child: Icon(Icons.check_circle_rounded, size: s * 0.5, color: const Color(0xFF43A047)),
                  ),
                ),
            ],
          ),
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0x33000000)),
        coin(0, _pool[0], right: true),
        coin(1, _pool[1], right: false),
        // 누른 자리에서 퍼지는 물결
        if (ripple > 0 && ripple < 1)
          Positioned(
            left: tapX - h * 0.12 * ripple,
            top: tapY - h * 0.12 * ripple,
            width: h * 0.24 * ripple,
            height: h * 0.24 * ripple,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 1 - ripple), width: h * 0.012),
              ),
            ),
          ),
        // 손가락(검지 끝이 누르는 자리에 오도록)
        Positioned(
          left: tapX - h * 0.05,
          top: tapY - h * 0.02 + (1 - press) * h * 0.06,
          child: Transform.scale(
            scale: 1 - (press > 0 && ripple < 0.3 ? 0.12 : 0),
            child: Icon(
              Icons.touch_app_rounded,
              size: h * 0.16,
              color: Colors.white,
              shadows: const [Shadow(color: Color(0x88000000), blurRadius: 6)],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: h * 0.06,
          child: Center(
            child: GestureDetector(
              onTap: _start,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: h * 0.1, vertical: h * 0.025),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A1F),
                  borderRadius: BorderRadius.circular(h),
                  border: Border.all(color: Colors.white, width: h * 0.008),
                  boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: Text('시작하기', style: _text(h * 0.065).copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 시작 전 하는 방법 텍스트 안내
  Widget _buildGuide() {
    final h = _size.height, icon = h * 0.1;
    Widget row(Widget image, String text) => Padding(
          padding: EdgeInsets.symmetric(vertical: h * 0.012),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: icon * 1.4, height: icon, child: image),
              SizedBox(width: h * 0.03),
              Text(text, style: _text(h * 0.05)),
            ],
          ),
        );
    return Container(
      color: const Color(0x99000000),
      alignment: Alignment.center,
      padding: EdgeInsets.all(h * 0.05),
      // 아이패드처럼 세로가 긴 화면에선 줄여서 맞춤
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: h * 0.07, vertical: h * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(h * 0.06),
            border: Border.all(color: const Color(0xFFF2A26B), width: h * 0.01),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('하니런 하는 방법', style: _text(h * 0.07)),
              SizedBox(height: h * 0.02),
              // 방법 줄들만 왼쪽 정렬, 묶음 자체는 가운데
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  row(_coin(_pool.first), '말풍선의 뜻과 소리에 맞는 한자 동전을 먹어요'),
                  row(Icon(Icons.swap_vert_rounded, size: icon, color: _brown), '화면 위·아래를 누르거나 밀어서 길을 바꿔요'),
                  row(Image.asset('$_dir/rock.png'), '돌과 쓰레기통은 피해요'),
                  row(Image.asset('$_dir/heart.png'), '틀리거나 부딪히면 하트가 줄어요'),
                ],
              ),
              SizedBox(height: h * 0.03),
              GestureDetector(
                onTap: _start,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: h * 0.1, vertical: h * 0.02),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A1F),
                    borderRadius: BorderRadius.circular(h),
                  ),
                  child: Text('시작하기', style: _text(h * 0.06).copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1, 2, 3, 시작! 숫자마다 크게 나타났다 작아짐
  Widget _buildCountdown() {
    final h = _size.height;
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_countdown),
          tween: Tween(begin: 1.6, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Text(
            _countdown!,
            style: _text(h * 0.22).copyWith(
              color: const Color(0xFFFF8A1F),
              shadows: const [
                Shadow(color: Colors.white, blurRadius: 2, offset: Offset(3, 3)),
                Shadow(color: Colors.white, blurRadius: 2, offset: Offset(-3, -3)),
                Shadow(color: Colors.white, blurRadius: 2, offset: Offset(3, -3)),
                Shadow(color: Colors.white, blurRadius: 2, offset: Offset(-3, 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _brown = Color(0xFF4E321C);

  TextStyle _text(double size) => TextStyle(fontFamily: 'BMJUA', fontSize: size, color: _brown, height: 1.1);

  Widget _buildHud(double h) {
    return Container(
      key: const ValueKey('hud'),
      padding: EdgeInsets.symmetric(horizontal: h * 0.35),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(h),
        border: Border.all(color: const Color(0xFFF2A26B), width: h * 0.09),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < HanjaRun.maxHearts; i++)
            Padding(
              padding: EdgeInsets.only(right: h * 0.08),
              child: Image.asset('$_dir/${i < _run.hearts ? 'heart' : 'heart_empty'}.png',
                  width: h * 0.45 * 69 / 56, height: h * 0.45),
            ),
          Container(
            width: 2,
            height: h * 0.4,
            margin: EdgeInsets.symmetric(horizontal: h * 0.2),
            color: const Color(0xFFF2A26B),
          ),
          Text('${NumberFormat('#,###').format(_run.score)}점', style: _text(h * 0.42)),
        ],
      ),
    );
  }
}
