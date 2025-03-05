import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/kidok/kidok_theme_data.dart';

class StrokePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> currentLine;
  final List<Path>? clipPath;
  final List<List<Path>> groupedPaths;
  final int currentPathIndex;
  final Set<int> completedPaths;
  final bool isSt0Completed;
  final Color strokeColor;

  StrokePainter(
    this.lines,
    this.currentLine, {
    this.clipPath,
    this.isSt0Completed = false,
    required this.groupedPaths,
    required this.currentPathIndex,
    required this.strokeColor,
    required this.completedPaths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. st0 (clipPath)를 배경으로 그리기 (항상 흰색 배경)
    if (clipPath != null && clipPath!.isNotEmpty) {
      final combinedClipPath =
          clipPath!.reduce((a, b) => Path.combine(PathOperation.union, a, b));
      canvas.clipPath(combinedClipPath);

      for (int i = clipPath!.length - 1; i >= 0; i--) {
        final path = clipPath![i];

        final fillPaint = Paint()
          ..color = completedPaths.contains(i) ? strokeColor : Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }
    }

    // 3. remainingPaths (st1, st2, st3)를 그리기 (가이드라인)
    // if (groupedPaths.isNotEmpty) {
    //   for (int groupIndex = 0; groupIndex < groupedPaths.length; groupIndex++) {
    //     for (final path in groupedPaths[groupIndex]) {
    //       final strokePaint = Paint()
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 2.0;
    //       if (completedPaths.contains(groupIndex)) {
    //         // 이미 완성한 획은 primaryColor의 실선으로 그리기
    //         strokePaint.color = primaryColor;
    //         canvas.drawPath(path, strokePaint);
    //       } else if (groupIndex == currentPathIndex) {
    //         // 현재 따라야 하는 획은 붉은 점선으로 그리기
    //         strokePaint.color = Colors.red;
    //         canvas.drawPath(
    //           dashPath(
    //             path,
    //             dashArray: CircularIntervalList<double>([10, 5]),
    //           ),
    //           strokePaint,
    //         );
    //       } else {
    //         // 아직 진행하지 않은 획은 회색 점선으로 그리기
    //         strokePaint.color = Colors.grey;
    //         canvas.drawPath(
    //           dashPath(
    //             path,
    //             dashArray: CircularIntervalList<double>([5, 5]),
    //           ),
    //           strokePaint,
    //         );
    //       }
    //     }
    //   }
    // }

    // 4. 사용자가 그린 라인 그리기
    final userPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 60.sp
      ..strokeCap = StrokeCap.round;

    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], userPaint);
      }
    }

    for (int i = 0; i < currentLine.length - 1; i++) {
      canvas.drawLine(currentLine[i], currentLine[i + 1], userPaint);
    }

    // 2. 경로 표시
    if (clipPath != null && currentPathIndex < clipPath!.length) {
      final path = clipPath![currentPathIndex];
      final pathMetrics = path.computeMetrics();

      final dotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      for (final metric in pathMetrics) {
        for (double t = 0; t < metric.length; t += 10.0) {
          final tangent = metric.getTangentForOffset(t);
          if (tangent != null) {
            final position = tangent.position;
            final normal = Offset(-tangent.vector.dy, tangent.vector.dx); // 수직 벡터

            final double offsetAmount = -2.0; // 안쪽으로 이동할 거리
            final adjustedPosition = position + normal * offsetAmount;

            canvas.drawCircle(adjustedPosition, 2.0, dotPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
