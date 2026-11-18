import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hani_booki/utils/sound_manager.dart';

/// 스프레이 브러쉬로 덮개 이미지를 긁어내는 위젯.
/// 굵은 중심선 + 주변에 흩뿌린 알갱이로 지우고, [threshold]% 지우면 덮개가 서서히 사라진다.
class SprayScratcher extends StatefulWidget {
  final Widget child;
  final String coverAsset;
  final double brushSize;
  final double threshold;
  final VoidCallback? onThreshold;

  const SprayScratcher({
    super.key,
    required this.child,
    required this.coverAsset,
    required this.brushSize,
    this.threshold = 75,
    this.onThreshold,
  });

  @override
  State<SprayScratcher> createState() => _SprayScratcherState();
}

class _SprayScratcherState extends State<SprayScratcher> {
  static const _grid = 40; // 진행률 체크 격자 (40x40)
  static const _dotSizes = [3.0, 5.0, 8.0];

  final _rand = Random();
  final _repaint = ValueNotifier(0);
  final _strokes = <List<Offset>>[];
  final _dots = [<Offset>[], <Offset>[], <Offset>[]];
  late final ImageStream _stream;
  late final ImageStreamListener _listener;
  ui.Image? _cover;
  Set<int>? _remaining;
  int _total = 0;
  bool _done = false;
  Timer? _still; // 손가락이 멈춰 있으면 모래 소리 끔

  @override
  void initState() {
    super.initState();
    _listener = ImageStreamListener((info, _) => setState(() => _cover = info.image));
    _stream = AssetImage(widget.coverAsset).resolve(ImageConfiguration.empty)..addListener(_listener);
  }

  @override
  void dispose() {
    _still?.cancel();
    SoundManager.stopSand();
    _stream.removeListener(_listener);
    _repaint.dispose();
    super.dispose();
  }

  /// 움직이는 동안만 모래 소리. 150ms 동안 안 움직이면 멈춤
  void _sand() {
    if (_done) return;
    SoundManager.startSand();
    _still?.cancel();
    _still = Timer(const Duration(milliseconds: 150), SoundManager.stopSand);
  }

  void _start(Offset p) {
    _strokes.add([p]);
    _spray(p, p);
  }

  void _move(Offset p) {
    final a = _strokes.last.last;
    _strokes.last.add(p);
    _spray(a, p);
  }

  void _spray(Offset a, Offset b) {
    final r = widget.brushSize / 2;
    final dist = (b - a).distance;

    // 알갱이: 중심선 바깥까지 흩뿌림 (가운데일수록 촘촘)
    final n = (dist * 0.6).clamp(6, 40).round();
    for (var i = 0; i < n; i++) {
      final c = Offset.lerp(a, b, _rand.nextDouble())!;
      final ang = _rand.nextDouble() * 2 * pi;
      final d = r * 1.25 * sqrt(_rand.nextDouble());
      _dots[_rand.nextInt(3)].add(c + Offset(cos(ang), sin(ang)) * d);
    }

    // 아직 덮여 있던 곳을 긁었을 때만 모래 소리 (이미 지운 곳은 조용)
    if (_updateProgress(a, b, r * 0.9)) _sand();
    _repaint.value++;
  }

  /// 이번에 새로 지운 칸이 있으면 true
  bool _updateProgress(Offset a, Offset b, double radius) {
    final size = context.size!;
    final remaining = _remaining ??= {for (var i = 0; i < _grid * _grid; i++) i};
    if (_total == 0) _total = remaining.length;

    final cw = size.width / _grid, ch = size.height / _grid;
    var erased = false;
    final steps = max(1, ((b - a).distance / 4).ceil());
    for (var s = 0; s <= steps; s++) {
      final p = Offset.lerp(a, b, s / steps)!;
      final x0 = max(0, ((p.dx - radius) / cw).floor()), x1 = min(_grid - 1, ((p.dx + radius) / cw).ceil());
      final y0 = max(0, ((p.dy - radius) / ch).floor()), y1 = min(_grid - 1, ((p.dy + radius) / ch).ceil());
      for (var x = x0; x <= x1; x++) {
        for (var y = y0; y <= y1; y++) {
          final cell = Offset((x + 0.5) * cw, (y + 0.5) * ch);
          if ((cell - p).distance <= radius && remaining.remove(y * _grid + x)) erased = true;
        }
      }
    }

    final progress = (1 - remaining.length / _total) * 100;
    if (!_done && progress >= widget.threshold) {
      setState(() => _done = true);
      _still?.cancel();
      SoundManager.stopSand();
      SoundManager.playSparkle(); // 덮개가 사라질 때 샤라라
      widget.onThreshold?.call();
    }
    return erased;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: _done,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => _start(d.localPosition),
            onPanUpdate: (d) => _move(d.localPosition),
            onPanEnd: (_) => SoundManager.stopSand(),
            onPanCancel: SoundManager.stopSand,
            child: AnimatedOpacity(
              opacity: _done ? 0 : 1,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              child: CustomPaint(
                size: Size.infinite,
                painter: _SprayPainter(
                  repaint: _repaint,
                  cover: _cover,
                  strokes: _strokes,
                  dots: _dots,
                  dotSizes: _dotSizes,
                  coreWidth: widget.brushSize * 0.75,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SprayPainter extends CustomPainter {
  final ui.Image? cover;
  final List<List<Offset>> strokes;
  final List<List<Offset>> dots;
  final List<double> dotSizes;
  final double coreWidth;

  _SprayPainter({
    required Listenable repaint,
    required this.cover,
    required this.strokes,
    required this.dots,
    required this.dotSizes,
    required this.coreWidth,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());

    if (cover != null) {
      paintImage(canvas: canvas, rect: rect, image: cover!, fit: BoxFit.cover);
    } else {
      canvas.drawRect(rect, Paint()..color = const Color(0xFFF2C77E)); // 이미지 로딩 전 모래색
    }

    final clear = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = coreWidth;
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawPoints(ui.PointMode.points, s, clear);
      } else {
        canvas.drawPath(Path()..addPolygon(s, false), clear);
      }
    }
    for (var i = 0; i < dots.length; i++) {
      canvas.drawPoints(ui.PointMode.points, dots[i], clear..strokeWidth = dotSizes[i]);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SprayPainter old) => old.cover != cover || old.coreWidth != coreWidth;
}
