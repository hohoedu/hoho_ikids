import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/colors.dart';
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

/// st1을 기준으로 그룹화하는 함수
List<List<StrokePath>> groupPathsBySt1(List<StrokePath> strokes) {
  List<List<StrokePath>> groups = [];
  List<StrokePath> currentGroup = [];
  for (var stroke in strokes) {
    if (stroke.strokeClass == 'st1') {
      // 새로운 그룹의 시작
      if (currentGroup.isNotEmpty) {
        groups.add(currentGroup);
      }
      currentGroup = [stroke];
    } else {
      // st1이 아닌 경우 현재 그룹에 추가
      currentGroup.add(stroke);
    }
  }
  if (currentGroup.isNotEmpty) {
    groups.add(currentGroup);
  }
  return groups;
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
    required this.isPointerShown,
    required this.strokeColor,
  });

  @override
  State<StrokeWord> createState() => _StrokeWordState();
}

class _StrokeWordState extends State<StrokeWord> {
  final customGloblaKey = GlobalKey();
  List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];
  double _top = 100;
  double _left = 100;
  List<Path>? firstPaths;
  List<StrokePath> remainingStrokePaths = [];
  List<List<Path>> groupedPaths = [];
  int currentGroupIndex = 0;
  Set<int> completedPaths = {};

  @override
  void initState() {
    super.initState();
    widget.resetNotifier.addListener(_onReset);
  }

  @override
  void didUpdateWidget(covariant StrokeWord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        firstPaths = null;
      });
    }
  }

  void _onReset() {
    resetTracing();
  }

  void _updatePointerPositionWithinBounds(Offset localPosition) {
    RenderBox renderBox =
        customGloblaKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    setState(() {
      _left = localPosition.dx.clamp(0.0, size.width - 50.w);
      _top = localPosition.dy.clamp(0.0, size.height - 50.h);
    });
  }

  Future<void> _loadSvgPathFromServer(Size size, int currentIndex) async {
    try {
      final response = await Dio().get(
          widget.strokeController.haniStrokeDataList[currentIndex].imagePath);

      if (response.statusCode == 200) {
        final svgData = response.data;
        final st0PathData =
            SvgPathParser.getPathsByClassFromData(svgData, 'st0');
        if (st0PathData.isNotEmpty) {
          setState(() {
            const svgSize = Size(200, 248);
            final scaleX = size.width / svgSize.width;
            final scaleY = size.height / svgSize.height;

            firstPaths = st0PathData.map((pathData) {
              final path = parseSvgPathData(pathData);
              return path.transform(
                  Matrix4.diagonal3Values(scaleX, scaleY, 1).storage);
            }).toList();
          });
        } else {
          Logger().d("class='st0' 속성을 가진 path 데이터를 찾을 수 없습니다.");
        }

        final allElements = SvgPathParser.getAllElementsFromData(svgData);
        setState(() {
          remainingStrokePaths = allElements
              .where((element) {
                final classAttr = (element['class'] as String?)?.trim() ?? '';
                return classAttr.contains('st1') ||
                    classAttr.contains('st2') ||
                    classAttr.contains('st3');
              })
              .map((element) {
                String? dAttribute;
                if (element['type'] == 'path') {
                  dAttribute = element['d'];
                } else if (element['type'] == 'line') {
                  dAttribute =
                      'M${element['x1']},${element['y1']} L${element['x2']},${element['y2']}';
                }
                if (dAttribute != null) {
                  final path = parseSvgPathData(dAttribute).transform(
                      Matrix4.diagonal3Values(
                              size.width / 200, size.height / 248, 1)
                          .storage);
                  final strokeClass =
                      (element['class'] as String?)?.trim() ?? '';
                  return StrokePath(path: path, strokeClass: strokeClass);
                }
                return null;
              })
              .where((s) => s != null)
              .cast<StrokePath>()
              .toList();

          List<List<StrokePath>> groups = groupPathsBySt1(remainingStrokePaths);

          groupedPaths =
              groups.map((group) => group.map((s) => s.path).toList()).toList();

          if (remainingStrokePaths.isNotEmpty) {
            _updatePointerPositionForGroup(currentGroupIndex);
          }
        });
      } else {
        Logger().e("SVG 데이터를 서버로부터 가져오는 데 실패했습니다.");
      }
    } catch (e) {
      Logger().e("SVG 데이터를 불러오는 중 오류 발생: $e");
    }
  }
  // Future<void> _loadSvgPathFromAssets(Size size, int currentIndex) async {
  //   try {
  //     final svgData = await rootBundle.loadString('assets/images/sun.svg');
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

  //     List<List<Path>> groupPaths(List<Path> paths, int groupSize) {
  //       List<List<Path>> groups = [];
  //       for (int i = 0; i < paths.length; i += groupSize) {
  //         int endIndex =
  //         (i + groupSize) > paths.length ? paths.length : (i + groupSize);
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
  //         final classAttr = (element['class'])?.trim() ?? '';
  //         return classAttr.contains('st1') ||
  //             classAttr.contains('st2') ||
  //             classAttr.contains('st3');
  //       })
  //           .map((element) {
  //         String? dAttribute;
  //         if (element['type'] == 'path') {
  //           dAttribute = element['d'];
  //         } else if (element['type'] == 'line') {
  //           dAttribute =
  //           'M${element['x1']},${element['y1']} L${element['x2']},${element['y2']}';
  //         }
  //         if (dAttribute != null) {
  //           final path = parseSvgPathData(dAttribute).transform(
  //               Matrix4.diagonal3Values(
  //                   size.width / 200, size.height / 248, 1)
  //                   .storage);
  //           final strokeClass = (element['class'] as String?)?.trim() ?? '';
  //           return StrokePath(path: path, strokeClass: strokeClass);
  //         }
  //         return null;
  //       })
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

  void _updatePointerPositionForGroup(int groupIndex) {
    if (groupIndex < groupedPaths.length &&
        groupedPaths[groupIndex].isNotEmpty) {
      final pathMetric = groupedPaths[groupIndex][0].computeMetrics().first;
      final startPoint = pathMetric.getTangentForOffset(0)?.position;
      if (startPoint != null) {
        setState(() {
          _top = startPoint.dy - 25;
          _left = startPoint.dx - 25;
        });
      }
    }
  }

  bool _isCurrentGroupCompleted(List<Offset> drawnLine, List<Path> group) {
    for (final path in group) {
      bool pathCompleted = false;
      for (final metric in path.computeMetrics()) {
        for (double t = 0; t < metric.length; t += 1) {
          final tangent = metric.getTangentForOffset(t);
          if (tangent != null) {
            for (final offset in drawnLine) {
              if ((tangent.position - offset).distance < 5.0) {
                pathCompleted = true;
                break;
              }
            }
          }
          if (pathCompleted) break;
        }
        if (pathCompleted) break;
      }
      if (!pathCompleted) return false;
    }
    return true;
  }

  void resetTracing() {
    setState(() {
      _lines.clear();
      _currentLine.clear();
      currentGroupIndex = 0;
      completedPaths.clear();
      _updatePointerPositionForGroup(currentGroupIndex);
    });
  }

  void _handlePan(DragUpdateDetails? updateDetails,
      {DragStartDetails? startDetails, DragEndDetails? endDetails}) {
    RenderBox renderBox =
        customGloblaKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = updateDetails?.localPosition ??
        startDetails?.localPosition ??
        endDetails?.localPosition;

    if (localPosition != null) {
      _updatePointerPositionWithinBounds(localPosition);
    }
    setState(() {
      if (startDetails != null) {
        _currentLine = [startDetails.localPosition];
        _top = startDetails.localPosition.dy - 25;
        _left = startDetails.localPosition.dx - 25;
      } else if (updateDetails != null) {
        _currentLine.add(updateDetails.localPosition);
        _top = updateDetails.localPosition.dy - 25;
        _left = updateDetails.localPosition.dx - 25;
      } else if (endDetails != null) {
        _lines.add(List.from(_currentLine));

        if (_isCurrentGroupCompleted(
            _currentLine, groupedPaths[currentGroupIndex])) {
          completedPaths.add(currentGroupIndex);
          currentGroupIndex++;

          _lines.removeLast();

          if (currentGroupIndex >= groupedPaths.length) {
            widget.onComplete();
          } else {
            _updatePointerPositionForGroup(currentGroupIndex);
          }
        } else {
          _lines.removeLast();
          _updatePointerPositionForGroup(currentGroupIndex);
        }

        _currentLine.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (firstPaths == null) {
          _loadSvgPathFromServer(
              Size(constraints.maxWidth, constraints.maxHeight),
              widget.currentIndex);
        }
        return GestureDetector(
          onPanStart: (details) => _handlePan(null, startDetails: details),
          onPanUpdate: (details) => _handlePan(details),
          onPanEnd: (details) => _handlePan(null, endDetails: details),
          child: Stack(
            children: [
              CustomPaint(
                key: customGloblaKey,
                size: Size.infinite,
                painter: StrokePainter(
                  _lines,
                  _currentLine,
                  clipPath: firstPaths,
                  groupedPaths: groupedPaths,
                  currentPathIndex: currentGroupIndex,
                  completedPaths: completedPaths,
                  isSt0Completed: currentGroupIndex >= groupedPaths.length,
                  strokeColor: widget.strokeColor,
                ),
              ),
              Visibility(
                visible: widget.isPointerShown,
                child: Positioned(
                  top: _top,
                  left: _left,
                  child: SizedBox(
                    height: 50,
                    width: 50,
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
