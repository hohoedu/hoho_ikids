import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_data/booki/booki_stroke_data.dart';
import 'package:hani_booki/utils/get_svg_path.dart';
import 'package:logger/logger.dart';
import 'package:path_drawing/path_drawing.dart';

import 'booki_stroke_horizontal_painter.dart';

class BookiStrokeHorizontalPath {
  final Path path;
  final String strokeClass;

  BookiStrokeHorizontalPath({required this.path, required this.strokeClass});
}

class BookiStrokeHorizontalWord extends StatefulWidget {
  final BookiStrokeDataController strokeController;
  final ValueNotifier<bool> resetNotifier;
  final int currentIndex;
  final VoidCallback onComplete;
  final bool isPointerShown;
  final Color strokeColor;

  const BookiStrokeHorizontalWord({
    super.key,
    required this.strokeController,
    required this.resetNotifier,
    required this.currentIndex,
    required this.onComplete,
    required this.strokeColor,
    required this.isPointerShown,
  });

  @override
  State<BookiStrokeHorizontalWord> createState() => _BookiStrokeHorizontalWordState();
}

class _BookiStrokeHorizontalWordState extends State<BookiStrokeHorizontalWord> {
  final customGlobalKey = GlobalKey();

  final List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];

  double _pointerTop = 100;
  double _pointerLeft = 100;

  List<Path>? clipPaths;
  List<Path>? pointerPaths;
  List<BookiStrokeHorizontalPath> guideStrokePaths = [];

  double scratchPercent = 0.0;
  final Set<int> completedPaths = {};
  int _currentPathIndex = 0;
  int? _lastIndex;

  static const Size kSvgViewport = Size(248, 200);

  @override
  void initState() {
    super.initState();
    widget.resetNotifier.addListener(_onReset);
  }

  void _onReset() {
    setState(() {
      _lines.clear();
      _currentLine.clear();
      completedPaths.clear();
      _currentPathIndex = 0;
      scratchPercent = 0.0;
      _updatePointerFromGuide();
    });
  }

  Future<void> _loadSvgFromAssets(Size canvasSize, int currentIndex) async {
    try {
      final svgData = await rootBundle.loadString('assets/images/mountain.svg');

      final st0List = SvgPathParser.getPathsByClassFromData(svgData, 'st0');

      final st1List = SvgPathParser.getPathsByClassFromData(svgData, 'st1');

      final allElements = SvgPathParser.getAllElementsFromData(svgData);

      final scale = _computeScale(canvasSize, kSvgViewport);
      final off = _computeOffset(canvasSize, kSvgViewport, scale);

      final Matrix4 m = Matrix4.identity()
        ..translate(off.dx, off.dy)
        ..scale(scale, scale);

      setState(() {
        clipPaths = st0List.map((d) => parseSvgPathData(d).transform(m.storage)).toList();

        pointerPaths = st1List.isEmpty ? null : st1List.map((d) => parseSvgPathData(d).transform(m.storage)).toList();

        guideStrokePaths = allElements
            .where((e) {
              final cls = (e['class'] as String?)?.trim() ?? '';
              return cls.contains('st1') || cls.contains('st2') || cls.contains('st3');
            })
            .map((e) {
              String? d;
              if (e['type'] == 'path') {
                d = e['d'];
              } else if (e['type'] == 'line') {
                d = 'M${e['x1']},${e['y1']} L${e['x2']},${e['y2']}';
              }
              if (d == null) return null;
              final p = parseSvgPathData(d).transform(m.storage);
              final cls = (e['class'] as String?)?.trim() ?? '';
              return BookiStrokeHorizontalPath(path: p, strokeClass: cls);
            })
            .whereType<BookiStrokeHorizontalPath>()
            .toList();

        _updatePointerFromGuide();
      });
    } catch (e) {
      Logger().e('SVG load error: $e');
    }
  }

  Future<void> _loadSvgFromServer(Size canvasSize, int currentIndex) async {
    try {
      final response = await Dio().get(widget.strokeController.bookiStrokeDataList[currentIndex].imagePath);

      final svgData = response.data!;

      final st0List = SvgPathParser.getPathsByClassFromData(svgData, 'st0');
      final st1List = SvgPathParser.getPathsByClassFromData(svgData, 'st1');
      final allElements = SvgPathParser.getAllElementsFromData(svgData);

      final scale = _computeScale(canvasSize, kSvgViewport);
      final off = _computeOffset(canvasSize, kSvgViewport, scale);
      final Matrix4 m = Matrix4.identity()
        ..translate(off.dx, off.dy)
        ..scale(scale, scale);

      setState(() {
        clipPaths = st0List.map((d) => parseSvgPathData(d).transform(m.storage)).toList();

        pointerPaths = st1List.isEmpty ? null : st1List.map((d) => parseSvgPathData(d).transform(m.storage)).toList();

        guideStrokePaths = allElements
            .where((e) {
              final cls = (e['class'] as String?)?.trim() ?? '';
              return cls.contains('st1') || cls.contains('st2') || cls.contains('st3');
            })
            .map((e) {
              String? d;
              if (e['type'] == 'path') {
                d = e['d'];
              } else if (e['type'] == 'line') {
                d = 'M${e['x1']},${e['y1']} L${e['x2']},${e['y2']}';
              }
              if (d == null) return null;
              final p = parseSvgPathData(d).transform(m.storage);
              final cls = (e['class'] as String?)?.trim() ?? '';
              return BookiStrokeHorizontalPath(path: p, strokeClass: cls);
            })
            .whereType<BookiStrokeHorizontalPath>()
            .toList();

        _updatePointerFromGuide();
      });
    } catch (e) {
      Logger().e('SVG load(server) error: $e');
    }
  }

  double _computeScale(Size canvas, Size svg) {
    final sx = canvas.width / svg.width;
    final sy = canvas.height / svg.height;
    return sx < sy ? sx : sy;
  }

  Offset _computeOffset(Size canvas, Size svg, double scale) {
    final w = svg.width * scale;
    final h = svg.height * scale;
    final dx = (canvas.width - w) / 2;
    final dy = (canvas.height - h) / 2;
    return Offset(dx, dy);
  }

  void _updatePointerFromGuide() {
    if (pointerPaths != null && _currentPathIndex < pointerPaths!.length) {
      final metric = pointerPaths![_currentPathIndex].computeMetrics().firstOrNull;
      final start = metric?.getTangentForOffset(0)?.position;
      if (start != null) {
        _pointerLeft = start.dx - 25;
        _pointerTop = start.dy - 25;
        setState(() {});
        return;
      }
    }
    if (clipPaths != null && _currentPathIndex < clipPaths!.length) {
      final metric = clipPaths![_currentPathIndex].computeMetrics().firstOrNull;
      final start = metric?.getTangentForOffset(0)?.position;
      if (start != null) {
        _pointerLeft = start.dx - 25;
        _pointerTop = start.dy - 25;
        setState(() {});
      }
    }
  }

  Future<void> _calcScratchPercent(Size size) async {
    if (clipPaths == null || clipPaths!.isEmpty || _currentPathIndex >= clipPaths!.length) return;

    final target = clipPaths![_currentPathIndex];

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    canvas.save();
    canvas.clipPath(target);

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 56
      ..strokeCap = StrokeCap.round;

    for (final line in _lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    int total = 0, filled = 0;

    final bounds = target.getBounds().intersect(Offset.zero & size);
    final left = bounds.left.floor().clamp(0, size.width.toInt());
    final top = bounds.top.floor().clamp(0, size.height.toInt());
    final right = bounds.right.ceil().clamp(0, size.width.toInt());
    final bottom = bounds.bottom.ceil().clamp(0, size.height.toInt());

    for (int y = top; y < bottom; y++) {
      for (int x = left; x < right; x++) {
        final idx = (y * size.width.toInt() + x) * 4;
        final r = bytes[idx];
        final g = bytes[idx + 1];
        final b = bytes[idx + 2];

        final pt = Offset(x.toDouble(), y.toDouble());
        if (target.contains(pt)) {
          total++;
          if (!(r == 255 && g == 255 && b == 255)) filled++;
        }
      }
    }

    final percent = total == 0 ? 0.0 : (filled / total);

    setState(() => scratchPercent = percent);

    if (percent >= 0.8 && !completedPaths.contains(_currentPathIndex)) {
      completedPaths.add(_currentPathIndex);
      if (_currentPathIndex < (clipPaths!.length - 1)) {
        setState(() {
          _currentPathIndex++;
          _lines.clear();
          _currentLine = [];
          scratchPercent = 0.0;
          _updatePointerFromGuide();
        });
      } else {
        widget.onComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final canvasSize = Size(cons.maxWidth, cons.maxHeight);

      if (clipPaths == null || _lastIndex != widget.currentIndex) {
        _lastIndex = widget.currentIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            clipPaths = null;
            pointerPaths = null;
            guideStrokePaths.clear();
            _lines.clear();
            _currentLine = [];
            completedPaths.clear();
            _currentPathIndex = 0;
            scratchPercent = 0.0;
          });
        });
        _loadSvgFromAssets(canvasSize, widget.currentIndex);
        // _loadSvgFromServer(canvasSize, widget.currentIndex);
      }

      return GestureDetector(
        onPanUpdate: (d) {
          final box = customGlobalKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;
          final pos = box.globalToLocal(d.globalPosition);

          setState(() {
            _currentLine.add(pos);
            _pointerLeft = pos.dx - 25;
            _pointerTop = pos.dy - 25;
          });
        },
        onPanEnd: (_) {
          setState(() {
            if (_currentLine.isNotEmpty) _lines.add(List.of(_currentLine));
            _currentLine = [];
          });
          _calcScratchPercent(canvasSize);
        },
        child: Stack(
          children: [
            CustomPaint(
              key: customGlobalKey,
              size: Size.infinite,
              painter: BookiStrokeHorizontalPainter(
                lines: _lines,
                currentLine: _currentLine,
                clipPath: clipPaths,
                guideStrokePaths: guideStrokePaths.map((e) => e.path).toList(),
                currentPathIndex: _currentPathIndex,
                completedPaths: completedPaths,
                isPointerShown: widget.isPointerShown,
                scratchPercent: scratchPercent,
                strokeColor: widget.strokeColor,
              ),
            ),
            if (widget.isPointerShown)
              Positioned(
                top: _pointerTop,
                left: _pointerLeft,
                child: SizedBox(
                  height: 50.h,
                  child: Image.asset('assets/images/icons/booki_pointer.png'),
                ),
              ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_onReset);
    super.dispose();
  }
}

extension _IterableMetricX on Iterable<PathMetric> {
  PathMetric? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
