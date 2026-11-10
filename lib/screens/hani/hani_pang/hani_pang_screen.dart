import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_board.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:intl/intl.dart';

/// 한자팡: 같은 한자 블록 3개 이상 맞추기. 제한 시간 동안 점수를 모은다.
class HaniPangScreen extends StatefulWidget {
  const HaniPangScreen({super.key, this.random});

  /// 테스트에서 보드를 고정할 때만 넘김
  final Random? random;

  @override
  State<HaniPangScreen> createState() => _HaniPangScreenState();
}

/// 화면에 그려지는 블록 위치 (보드 로직과 따로 움직여야 애니메이션이 단계별로 보임)
class _Cell {
  _Cell(this.tile, this.row, this.col);

  final Tile tile;
  int row, col;
}

class _Fx {
  _Fx(this.id, this.type, this.pos);

  final int id;
  final Special type;
  final Pos pos;
}

class _HaniPangScreenState extends State<HaniPangScreen> with SingleTickerProviderStateMixin {
  static const _dir = 'assets/images/hani/pang';
  static const rows = 5, cols = 8;
  static const _kindsPerGame = 6; // 블록 8종 중 한 판에 쓰는 수 (적을수록 쉬움)
  static const _pointPerBlock = 100;
  static const _gameTime = Duration(seconds: 60);

  static const _move = Duration(milliseconds: 200);
  static const _clear = Duration(milliseconds: 220);
  static const _fall = Duration(milliseconds: 260);

  // 시안(2000x924) 비율로 고정한 무대
  static const _stageAspect = 2000 / 924;

  late final Random _rand = widget.random ?? Random();
  late final AnimationController _timer = AnimationController(vsync: this, duration: _gameTime)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _maybeEnd();
    });

  late Board _board;
  late List<int> _kinds; // 보드 색 번호 → 블록 이미지 번호(1~8)
  late int _bonusColor;
  final _view = <int, _Cell>{};
  final _clearing = <int>{};
  final _hiddenSpecial = <int>{}; // 아직 생기기 전 단계인 특수 블록
  final _fx = <_Fx>[];
  int _fxSeq = 0;
  int _score = 0;
  bool _busy = false;
  bool _over = false;
  Pos? _selected;
  Pos? _dragFrom;
  Offset _dragOrigin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  @visibleForTesting
  Board get board => _board;

  void _newGame() {
    _kinds = ([for (var i = 1; i <= 8; i++) i]..shuffle(_rand)).take(_kindsPerGame).toList();
    _bonusColor = _rand.nextInt(_kindsPerGame);
    _board = Board(rows: rows, cols: cols, colorCount: _kindsPerGame, random: _rand);
    _syncView();
    _score = 0;
    _over = false;
    _selected = null;
    _timer.forward(from: 0);
  }

  void _syncView() {
    _view
      ..clear()
      ..addAll({for (final (p, t) in _board.tiles) t.id: _Cell(t, p.row, p.col)});
  }

  String _blockAsset(int color) => '$_dir/block-y0${_kinds[color]}.png';

  Future<void> _wait(Duration d) => Future.delayed(d);

  void _maybeEnd() {
    if (_busy || !_timer.isCompleted || _over) return;
    setState(() {
      _over = true;
      _selected = null;
    });
  }

  // ───────── 입력 ─────────

  void _tap(Pos p) {
    if (_busy || _over) return;
    final sel = _selected;
    if (sel != null && sel.isAdjacent(p)) {
      _trySwap(sel, p);
    } else {
      setState(() => _selected = sel == p ? null : p);
    }
  }

  void _drag(Pos from, Offset delta, double cell) {
    if (delta.distance < cell * 0.3) return;
    _dragFrom = null;
    final to = delta.dx.abs() > delta.dy.abs() ? Pos(from.row, from.col + delta.dx.sign.toInt()) : Pos(from.row + delta.dy.sign.toInt(), from.col);
    _trySwap(from, to);
  }

  // ───────── 진행 ─────────

  _Cell? _cellAt(Pos p) => _view.values.where((c) => c.row == p.row && c.col == p.col).firstOrNull;

  void _swapView(Pos a, Pos b) {
    final ca = _cellAt(a), cb = _cellAt(b);
    ca
      ?..row = b.row
      ..col = b.col;
    cb
      ?..row = a.row
      ..col = a.col;
  }

  Future<void> _trySwap(Pos a, Pos b) async {
    if (_busy || _over || !_board.inBounds(b)) return;
    _busy = true;
    final result = _board.swap(a, b);
    _hiddenSpecial.addAll([for (final s in result.steps) ...s.created.map((c) => c.tile.id)]);

    setState(() {
      _selected = null;
      _swapView(a, b);
    });
    await _wait(_move);
    if (!mounted) return;

    if (!result.valid) {
      setState(() => _swapView(a, b)); // 맞는 줄이 없으면 제자리로
      await _wait(_move);
    } else {
      for (final step in result.steps) {
        await _playStep(step);
        if (!mounted) return;
      }
      if (result.shuffled) {
        setState(_syncView);
        await _wait(_fall);
      }
    }
    if (!mounted) return;
    _busy = false;
    _maybeEnd();
  }

  Future<void> _playStep(CascadeStep step) async {
    // 1) 터짐 + 특수 효과
    setState(() {
      for (final t in step.triggered) {
        _fx.add(_Fx(_fxSeq++, t.type, t.pos));
      }
      _clearing.addAll(step.cleared.map((c) => c.tile.id));
      _hiddenSpecial.removeAll(step.created.map((c) => c.tile.id));
      final blocks = step.cleared.fold<int>(0, (s, c) => s + (c.tile.color == _bonusColor ? 2 : 1));
      _score += (blocks * _pointPerBlock * comboMultiplier(step.combo)).round();
    });
    final fxDone = _fxSeq;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _fx.removeWhere((f) => f.id < fxDone));
    });
    await _wait(_clear);
    if (!mounted) return;

    // 2) 지운 자리 비우고, 새 블록은 보드 위에서 출발
    setState(() {
      for (final c in step.cleared) {
        _view.remove(c.tile.id);
      }
      _clearing.clear();
      for (final f in step.falls.where((f) => f.isNew)) {
        _view[f.tile.id] = _Cell(f.tile, f.fromRow, f.col);
      }
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    // 3) 낙하
    setState(() {
      for (final f in step.falls) {
        _view[f.tile.id]?.row = f.toRow;
      }
    });
    await _wait(_fall);
  }

  // ───────── 화면 ─────────

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    final side = max(16.0, max(safe.left, safe.right)); // 가장자리 블록·막대가 노치에 안 가리게

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MainAppBar(isContent: false, title: ''),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('$_dir/pang_bg.png', fit: BoxFit.cover)),
          Padding(
            padding: EdgeInsets.fromLTRB(side, 8, side, max(8, safe.bottom)),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = min(c.maxWidth, c.maxHeight * _stageAspect);
                return Center(
                  child: SizedBox(width: w, height: w / _stageAspect, child: _buildStage(w, w / _stageAspect)),
                );
              },
            ),
          ),
          if (_over) _buildGameOver(),
        ],
      ),
    );
  }

  Widget _buildStage(double w, double h) {
    // 블록 한 칸 크기: 보드 자리(가로 61%, 세로 86.5%)에 8x5 + 테두리 여백이 들어가게
    final cell = min(w * 0.6125 / (cols + 0.4), h * 0.865 / (rows + 0.4));
    final boardW = cell * (cols + 0.4), boardH = cell * (rows + 0.4);
    final boardL = w * 0.3025, boardT = h * 0.532 - boardH / 2;
    final panelW = w * 0.24, panelH = panelW * 322 / 598;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: w * 0.0375, top: h * 0.21, width: panelW, height: panelH, child: _scorePanel(panelH)),
        Positioned(left: w * 0.0375, top: h * 0.535, width: panelW, height: panelH, child: _bonusPanel(panelH)),
        Positioned(left: boardL, top: boardT, width: boardW, height: boardH, child: _buildBoard(cell)),
        Positioned(
          left: boardL + boardW + cell * 0.2,
          top: boardT,
          width: cell * 0.75,
          height: boardH,
          child: _buildTimeBar(cell),
        ),
        // 보드 아래 모서리 나뭇잎 장식
        Positioned(
          left: boardL - cell * 0.35,
          top: boardT + boardH - cell * 0.65,
          width: cell * 1.1,
          child: IgnorePointer(child: Image.asset('$_dir/leaf01.png')),
        ),
        Positioned(
          left: boardL + boardW - cell * 0.6,
          top: boardT + boardH - cell * 0.6,
          width: cell * 1.1,
          child: IgnorePointer(child: Image.asset('$_dir/leaf02.png')),
        ),
      ],
    );
  }

  static const _green = Color(0xFF3F8F3A), _darkGreen = Color(0xFF22452A), _brown = Color(0xFF4E321C);

  BoxDecoration _frame(double cell) => BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(cell * 0.45),
        border: Border.all(color: _green, width: cell * 0.1),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3))],
      );

  TextStyle _text(double size) => TextStyle(fontFamily: 'NANUM-EB', fontSize: size, color: _brown, height: 1.2);

  Widget _scorePanel(double h) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('$_dir/wood.png', fit: BoxFit.fill),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('현재 점수', style: _text(h * 0.14)),
            Padding(
              padding: EdgeInsets.only(top: h * 0.04),
              child: Text('${NumberFormat('#,###').format(_score)}점', style: _text(h * 0.24)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bonusPanel(double h) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('$_dir/wood.png', fit: BoxFit.fill),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('보너스 블럭', style: _text(h * 0.14)),
            Padding(
              padding: EdgeInsets.only(top: h * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(_blockAsset(_bonusColor), width: h * 0.3, height: h * 0.3),
                  Padding(
                    padding: EdgeInsets.only(left: h * 0.06),
                    child: Text('X 2배', style: _text(h * 0.22)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBar(double cell) {
    final inset = cell * 0.16;
    return DecoratedBox(
      key: const ValueKey('timeBar'),
      decoration: _frame(cell).copyWith(borderRadius: BorderRadius.circular(cell)),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: AnimatedBuilder(
          animation: _timer,
          builder: (context, _) => Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 1 - _timer.value,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cell),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFD21F), Color(0xFFF7862A)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(double cell) {
    Pos at(Offset o) => Pos((o.dy / cell).floor().clamp(0, rows - 1), (o.dx / cell).floor().clamp(0, cols - 1));

    return DecoratedBox(
      key: const ValueKey('board'),
      decoration: _frame(cell),
      child: Padding(
        padding: EdgeInsets.all(cell * 0.2),
        child: ClipRect(
          // 위에서 떨어지는 새 블록은 보드 안에서만 보이게
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // 기본값(start)은 손가락이 좀 움직인 뒤 위치를 시작점으로 줘서, 빠르게 밀면 옆 칸을 잡음
            dragStartBehavior: DragStartBehavior.down,
            onTapUp: (d) => _tap(at(d.localPosition)),
            onPanStart: (d) {
              _dragFrom = at(d.localPosition);
              _dragOrigin = d.localPosition;
            },
            onPanUpdate: (d) {
              final from = _dragFrom;
              if (from == null || _busy || _over) return;
              _drag(from, d.localPosition - _dragOrigin, cell);
            },
            child: Stack(
              children: [
                for (final c in _view.values) _buildTile(c, cell),
                for (final f in _fx) _buildFx(f, cell),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(_Cell c, double cell) {
    final t = c.tile;
    final selected = _selected == Pos(c.row, c.col);
    final clearing = _clearing.contains(t.id);
    final special = _hiddenSpecial.contains(t.id) ? Special.none : t.special;

    return AnimatedPositioned(
      key: ValueKey(t.id),
      duration: _fall,
      curve: Curves.easeIn,
      left: c.col * cell,
      top: c.row * cell,
      width: cell,
      height: cell,
      child: AnimatedScale(
        scale: clearing ? 0 : (selected ? 1.12 : 1),
        duration: clearing ? _clear : const Duration(milliseconds: 120),
        child: Padding(
          padding: EdgeInsets.all(cell * 0.03),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(_blockAsset(t.color)),
              if (special != Special.none) CustomPaint(painter: _SpecialPainter(special)),
              if (selected)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cell * 0.25),
                    border: Border.all(color: Colors.white, width: cell * 0.06),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFx(_Fx f, double cell) {
    final Rect area = switch (f.type) {
      Special.laserH => Rect.fromLTWH(0, f.pos.row * cell, cols * cell, cell),
      Special.laserV => Rect.fromLTWH(f.pos.col * cell, 0, cell, rows * cell),
      _ => Rect.fromLTWH((f.pos.col - 1) * cell, (f.pos.row - 1) * cell, cell * 3, cell * 3),
    };
    return Positioned.fromRect(
      key: ValueKey('fx${f.id}'),
      rect: area,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 380),
          builder: (context, t, _) => Opacity(
            opacity: (1 - t).clamp(0, 1),
            child: f.type == Special.blackHole
                ? Transform.scale(
                    scale: 0.3 + t,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [Color(0xFF1B0B36), Color(0xCC8E5BFF), Color(0x008E5BFF)]),
                      ),
                    ),
                  )
                : Transform.scale(
                    scaleX: f.type == Special.laserH ? 1 : 0.4 + t * 0.6,
                    scaleY: f.type == Special.laserV ? 1 : 0.4 + t * 0.6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(cell),
                        gradient: LinearGradient(
                          begin: f.type == Special.laserH ? Alignment.topCenter : Alignment.centerLeft,
                          end: f.type == Special.laserH ? Alignment.bottomCenter : Alignment.centerRight,
                          colors: const [Color(0x00FFF59D), Colors.white, Color(0x00FFF59D)],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final pw = min(c.maxWidth * 0.45, 420.0), ph = pw * 322 / 598;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: pw,
                    height: ph,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('$_dir/wood.png', fit: BoxFit.fill),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('시간 끝!', style: _text(ph * 0.15)),
                            Padding(
                              padding: EdgeInsets.only(top: ph * 0.04),
                              child: Text('${NumberFormat('#,###').format(_score)}점', style: _text(ph * 0.24)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: ph * 0.1),
                    child: GestureDetector(
                      onTap: () => setState(_newGame),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: ph * 0.25, vertical: ph * 0.08),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7862A),
                          borderRadius: BorderRadius.circular(ph),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Text('다시 하기', style: _text(ph * 0.14).copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 특수 블록 표시: 레이저는 가로/세로 빛줄기, 블랙홀은 가운데 소용돌이
class _SpecialPainter extends CustomPainter {
  _SpecialPainter(this.type);

  final Special type;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.shortestSide;
    if (type == Special.blackHole) {
      canvas.drawCircle(
        c,
        s * 0.3,
        Paint()..shader = const RadialGradient(colors: [Color(0xFF12061F), Color(0xFF5A2DB8), Color(0x005A2DB8)]).createShader(Rect.fromCircle(center: c, radius: s * 0.3)),
      );
      canvas.drawCircle(
        c,
        s * 0.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.04
          ..color = Colors.white70,
      );
      return;
    }
    final horizontal = type == Special.laserH;
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = s * 0.16
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.06);
    final core = Paint()
      ..color = Colors.white
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;
    for (final d in [-0.22, 0.22]) {
      final a = horizontal ? Offset(s * 0.12, c.dy + s * d) : Offset(c.dx + s * d, s * 0.12);
      final b = horizontal ? Offset(s * 0.88, c.dy + s * d) : Offset(c.dx + s * d, s * 0.88);
      canvas.drawLine(a, b, glow);
      canvas.drawLine(a, b, core);
    }
  }

  @override
  bool shouldRepaint(_SpecialPainter old) => old.type != type;
}
