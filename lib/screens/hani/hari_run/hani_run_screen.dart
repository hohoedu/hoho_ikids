import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_data.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_logic.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

/// 하니런: 말풍선의 훈음에 맞는 한자 동전이 있는 길로 달려가 받는다. 돌·쓰레기통은 피한다.
class HaniRunScreen extends StatefulWidget {
  const HaniRunScreen({super.key, this.random, this.obstacles = true});

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

class _HaniRunScreenState extends State<HaniRunScreen> with SingleTickerProviderStateMixin {
  static const _dir = 'assets/images/hani/run';
  static const _bgAspect = 2160 / 724;

  // run_bg.png 세로 비율: 위 차선 중심, 가운데 점선, 아래 차선 중심
  static const _laneY = [0.4755, 0.6955];
  static const _dashY = 0.585;

  static const _baseTravel = 4.0; // 처음엔 화면 오른쪽에서 캐릭터까지 4초
  static const _firstCalmQuestions = 2; // 처음 몇 문제는 장애물 없음

  late final Random _rand = widget.random ?? Random();
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;

  late HanjaRun _run;
  late HanjaQuiz _quiz;
  HanjaQuestion? _question;
  final _things = <_Thing>[];
  double _nextSpawnIn = 1.0;
  int _lane = 0;
  double _bgOffset = 0;
  double _hurtUntil = 0;
  double _time = 0;
  ({String text, Color color, double at})? _toast;
  bool _over = false;

  Size _size = Size.zero;
  double _charX = 0;

  @visibleForTesting
  HanjaRun get run => _run;
  @visibleForTesting
  HanjaQuestion? get question => _question;

  @override
  void initState() {
    super.initState();
    _restart();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _restart() {
    _run = HanjaRun();
    _quiz = HanjaQuiz(random: _rand);
    _question = null;
    _things.clear();
    _nextSpawnIn = 1.0;
    _lane = 0;
    _toast = null;
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

    if (!_over) {
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
      _checkHits();
    }
    setState(() {});
  }

  void _spawn() {
    final q = _quiz.next();
    _question = q;
    var x = _size.width + _coinSize;
    // 장애물은 동전보다 먼저 와서, 피한 뒤 정답 길을 고를 시간이 있게
    if (widget.obstacles && _quiz.asked > _firstCalmQuestions && _rand.nextBool()) {
      _things.add(_Thing(_rand.nextBool() ? _Kind.rock : _Kind.trash, _rand.nextInt(2), x));
      x += _size.width * 0.38;
    }
    for (final side in Side.values) {
      _things.add(_Thing(_Kind.coin, side == Side.left ? 0 : 1, x, q.at(side)));
    }
  }

  void _checkHits() {
    for (final t in _things.where((t) => !t.done && t.x <= _charX)) {
      if (t.kind != _Kind.coin) {
        t.done = true;
        if (t.lane == _lane) {
          t.caught = true;
          _run.onCrash();
          _hurt('아야!', const Color(0xFFE53935));
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
        final gained = _run.onCorrect();
        _toast = (text: '+$gained', color: const Color(0xFFFF8A1F), at: _time);
      } else {
        _run.onMistake(q.target);
        _quiz.markMistake(q.target);
        _hurt('정답은 ${q.target.char} (${q.target.reading})', const Color(0xFFE53935));
      }
      _question = null;
      _nextSpawnIn = 0.6;
      _afterMistake();
      return;
    }
  }

  void _hurt(String text, Color color) {
    _hurtUntil = _time + 0.7;
    _toast = (text: text, color: color, at: _time);
  }

  void _afterMistake() {
    if (_run.isOver && !_over) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _over = true);
      });
    }
  }

  void _setLane(int lane) {
    if (_over || _run.isOver) return;
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
                Positioned(top: h * 0.03, right: side, height: h * 0.11, child: _buildHud(h * 0.11)),
                if (_over) _buildGameOver(),
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
      _Kind.coin => _coin(t.hanja!, size.width),
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

  Widget _coin(Hanja hanja, double size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('$_dir/coin_blank.png'),
        Center(
          child: Text(
            hanja.char,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF9D5F08),
              fontFamily: 'MPLUS-BOLD',
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacter() {
    final h = _size.height;
    final ch = h * 0.30, cw = ch * 560 / 878;
    final hurt = _time < _hurtUntil;
    return AnimatedPositioned(
      key: const ValueKey('character'),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      left: _charX - cw / 2,
      top: h * _laneY[_lane] - ch * 0.6,
      width: cw,
      height: ch,
      child: Opacity(
        // 부딪히면 깜빡임
        opacity: hurt && (_time * 10).floor().isEven ? 0.35 : 1,
        child: Lottie.asset('assets/lottie/mushroom_character.json', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBubble() {
    final q = _question;
    final h = _size.height;
    final bw = h * 0.37, bh = bw * 232 / 425;
    return Positioned(
      key: const ValueKey('bubble'),
      left: _charX + h * 0.09,
      top: h * 0.11,
      width: bw,
      height: bh,
      child: AnimatedOpacity(
        opacity: q == null ? 0 : 1,
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
                  child: Text(q?.target.reading ?? '', style: _text(bh * 0.32)),
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
              child: Image.asset('$_dir/${i < _run.hearts ? 'heart' : 'heart_empty'}.png', width: h * 0.45 * 69 / 56, height: h * 0.45),
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

  Widget _buildGameOver() {
    final h = _size.height;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: min(_size.width * 0.5, 460),
            padding: EdgeInsets.all(h * 0.05),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF9A6332), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('게임 끝!', style: _text(h * 0.08)),
                Padding(
                  padding: EdgeInsets.only(top: h * 0.02),
                  child: Text(
                    '${NumberFormat('#,###').format(_run.score)}점 · 맞힌 한자 ${_run.correctCount}개',
                    style: _text(h * 0.05),
                  ),
                ),
                if (_run.mistakes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.03),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final m in _run.mistakes)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2C79A)),
                            ),
                            child: Text('${m.char}  ${m.reading}', style: _text(h * 0.045)),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: h * 0.04),
                  child: GestureDetector(
                    onTap: () => setState(_restart),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: h * 0.08, vertical: h * 0.025),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7862A),
                        borderRadius: BorderRadius.circular(h),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Text('다시 하기', style: _text(h * 0.055).copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
