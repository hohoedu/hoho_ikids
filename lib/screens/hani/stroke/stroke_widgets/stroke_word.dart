import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_data/hani/hani_stroke_data.dart';
import 'package:hani_booki/screens/hani/stroke/stroke_widgets/stroke_painter.dart';
import 'package:hani_booki/utils/get_svg_path.dart';
import 'package:logger/logger.dart';
import 'package:path_drawing/path_drawing.dart';

class StrokePath {
  final Path path;
  final String strokeClass;

  StrokePath({required this.path, required this.strokeClass});
}

class StrokeWord extends StatefulWidget {
  final HaniStrokeDataController strokeController;
  final ValueNotifier<bool> resetNotifier;
  final int currentIndex;
  final VoidCallback onComplete;
  final bool isPointerShown;
  final Color strokeColor;

  const StrokeWord({
    super.key,
    required this.strokeController,
    required this.resetNotifier,
    required this.currentIndex,
    required this.onComplete,
    required this.strokeColor,
    required this.isPointerShown,
  });

  @override
  State<StrokeWord> createState() => _StrokeWordState();
}

class _StrokeWordState extends State<StrokeWord> {
  final customGlobalKey = GlobalKey();
  List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];
  double _top = 100;
  double _left = 100;
  List<Path>? firstPaths;
  List<Path>? pointerPaths;
  List<StrokePath> remainingStrokePaths = [];
  double scratchPercent = 0.0;
  Set<int> completedPaths = {};

  int? _lastIndex;
  int _currentPathIndex = 0;

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
      _updatePointer();
    });
  }

  //assets에서 SVG가져오기
  // Future<void> _loadSvgPathFromAssets(Size size, int currentIndex) async {
  //   try {
  //     final svgData = await rootBundle.loadString('assets/images/long.svg');
  //
  //     final st0PathData = SvgPathParser.getPathsByClassFromData(svgData, 'st0');
  //     if (st0PathData.isNotEmpty) {
  //       setState(() {
  //         const svgSize = Size(200, 248);
  //         final scaleX = size.width / svgSize.width;
  //         final scaleY = size.height / svgSize.height;
  //
  //         firstPaths = st0PathData.map((pathData) {
  //           final path = parseSvgPathData(pathData);
  //           return path
  //               .transform(Matrix4.diagonal3Values(scaleX, scaleY, 1).storage);
  //         }).toList();
  //       });
  //     } else {
  //       Logger().d("class='st0' 속성을 가진 path 데이터를 찾을 수 없습니다.");
  //     }
  //
  //     List<List<Path>> groupPaths(List<Path> paths, int groupSize) {
  //       List<List<Path>> groups = [];
  //       for (int i = 0; i < paths.length; i += groupSize) {
  //         int endIndex =
  //             (i + groupSize) > paths.length ? paths.length : (i + groupSize);
  //         groups.add(paths.sublist(i, endIndex));
  //       }
  //       return groups;
  //     }
  //
  //     final allElements = SvgPathParser.getAllElementsFromData(svgData);
  //
  //     setState(() {
  //       remainingStrokePaths = allElements
  //           .where((element) {
  //             final classAttr = (element['class'])?.trim() ?? '';
  //             return classAttr.contains('st1') ||
  //                 classAttr.contains('st2') ||
  //                 classAttr.contains('st3');
  //           })
  //           .map((element) {
  //             String? dAttribute;
  //             if (element['type'] == 'path') {
  //               dAttribute = element['d'];
  //             } else if (element['type'] == 'line') {
  //               dAttribute =
  //                   'M${element['x1']},${element['y1']} L${element['x2']},${element['y2']}';
  //             }
  //             if (dAttribute != null) {
  //               final path = parseSvgPathData(dAttribute).transform(
  //                   Matrix4.diagonal3Values(
  //                           size.width / 200, size.height / 248, 1)
  //                       .storage);
  //               final strokeClass = (element['class'] as String?)?.trim() ?? '';
  //               return StrokePath(path: path, strokeClass: strokeClass);
  //             }
  //             return null;
  //           })
  //           .where((s) => s != null)
  //           .cast<StrokePath>()
  //           .toList();
  //
  //       List<List<StrokePath>> groups = groupPathsBySt1(remainingStrokePaths);
  //
  //       groupedPaths =
  //           groups.map((group) => group.map((s) => s.path).toList()).toList();
  //
  //       if (remainingStrokePaths.isNotEmpty) {
  //         _updatePointerPositionForGroup(currentGroupIndex);
  //       }
  //     });
  //   } catch (e) {
  //     Logger().e("SVG 데이터를 불러오는 중 오류 발생: $e");
  //   }
  // }

  Future<void> _loadSvgPathFromServer(Size size, int currentIndex) async {
    try {
      final response = await Dio().get(widget.strokeController.haniStrokeDataList![currentIndex].imagePath);
      if (response.statusCode == 200) {
        final svgData = response.data;
        final st0PathData = SvgPathParser.getPathsByClassFromData(svgData, 'st0');
        final st1PathData = SvgPathParser.getPathsByClassFromData(svgData, 'st1');
        if (st0PathData.isNotEmpty) {
          setState(() {
            const svgSize = Size(200, 248);
            final scaleX = size.width / svgSize.width;
            final scaleY = size.height / svgSize.height;
            firstPaths = st0PathData.map((pathData) {
              final path = parseSvgPathData(pathData);
              return path.transform(Matrix4.diagonal3Values(scaleX, scaleY, 1).storage);
            }).toList();
          });
        }
        if (st1PathData.isNotEmpty) {
          setState(() {
            const svgSize = Size(200, 248);
            final scaleX = size.width / svgSize.width;
            final scaleY = size.height / svgSize.height;
            pointerPaths = st1PathData
                .map((d) => parseSvgPathData(d).transform(Matrix4.diagonal3Values(scaleX, scaleY, 1).storage))
                .toList();
            _updatePointer(); // 포인터 초기 위치 세팅
          });
        }
        final allElements = SvgPathParser.getAllElementsFromData(svgData);
        remainingStrokePaths = allElements.where((e) => ['st1', 'st2', 'st3'].contains(e['class'])).map((e) {
          String? d = e['type'] == 'path' ? e['d'] : 'M${e['x1']},${e['y1']} L${e['x2']},${e['y2']}';
          final path =
              parseSvgPathData(d!).transform(Matrix4.diagonal3Values(size.width / 200, size.height / 248, 1).storage);
          return StrokePath(path: path, strokeClass: e['class']!);
        }).toList();
        _updatePointer();
      }
    } catch (e) {
      Logger().e("SVG load error: $e");
    }
  }

  Future<void> _calculateScratchPercentAccurate(Size size) async {
    if (firstPaths == null || firstPaths!.length <= _currentPathIndex) return;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final path = firstPaths![_currentPathIndex];

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    canvas.save();
    canvas.clipPath(path);

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 60.sp
      ..strokeCap = StrokeCap.round;

    for (var line in _lines) {
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

    for (int y = 0; y < size.height.toInt(); y++) {
      for (int x = 0; x < size.width.toInt(); x++) {
        final index = (y * size.width.toInt() + x) * 4;
        final r = bytes[index];
        final g = bytes[index + 1];
        final b = bytes[index + 2];

        final point = Offset(x.toDouble(), y.toDouble());
        if (path.contains(point)) {
          total++;
          if (!(r == 255 && g == 255 && b == 255)) filled++;
        }
      }
    }

    final percent = filled / total;

    setState(() {
      scratchPercent = percent;
    });

    if (percent >= 0.8 && !completedPaths.contains(_currentPathIndex)) {
      completedPaths.add(_currentPathIndex);

      if (_currentPathIndex < firstPaths!.length - 1) {
        setState(() {
          _currentPathIndex++;
          _lines.clear();
          _currentLine.clear();
          scratchPercent = 0;
          _updatePointer();
        });
      } else {
        widget.onComplete();
      }
    }
  }

  void _updatePointer() {
    if (pointerPaths != null && _currentPathIndex < pointerPaths!.length) {
      final path = pointerPaths![_currentPathIndex];
      final metric = path.computeMetrics().first;
      final start = metric.getTangentForOffset(0)?.position;

      if (start != null) {
        setState(() {
          _left = start.dx - 25;
          _top = start.dy - 25;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (firstPaths == null || _lastIndex != widget.currentIndex) {
          _lastIndex = widget.currentIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              firstPaths = null;
              _lines.clear();
              _currentLine.clear();
              completedPaths.clear();
              _currentPathIndex = 0;
              scratchPercent = 0.0;
            });
          });

          _loadSvgPathFromServer(Size(constraints.maxWidth, constraints.maxHeight), widget.currentIndex);
        }
        return GestureDetector(
          onPanUpdate: (d) {
            RenderBox box = customGlobalKey.currentContext!.findRenderObject() as RenderBox;
            final pos = box.globalToLocal(d.globalPosition);

            setState(() {
              _currentLine.add(pos);
              _top = pos.dy - 25;
              _left = pos.dx - 25;
            });
          },
          onPanEnd: (_) {
            setState(() {
              _lines.add(_currentLine);
              _currentLine = [];
            });
            _calculateScratchPercentAccurate(constraints.biggest);
          },
          child: Stack(
            children: [
              CustomPaint(
                key: customGlobalKey,
                size: Size.infinite,
                painter: StrokePainter(
                  _lines,
                  _currentLine,
                  clipPath: firstPaths,
                  completedPaths: completedPaths,
                  scratchPercent: scratchPercent,
                  groupedPaths: [],
                  isPointerShown: widget.isPointerShown,
                  currentPathIndex: _currentPathIndex,
                  strokeColor: widget.strokeColor,
                ),
              ),
              Visibility(
                visible: widget.isPointerShown,
                child: Positioned(
                  top: _top,
                  left: _left,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Image.asset('assets/images/icons/pointer.png'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_onReset);
    super.dispose();
  }
}
