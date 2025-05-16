import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

class StrokePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> currentLine;
  final List<Path>? clipPath;
  final List<List<Path>> groupedPaths;
  final int currentPathIndex;
  final Set<int> completedPaths;
  final bool isSt0Completed;
  final bool isPointerShown;
  final double scratchPercent;
  final Color strokeColor;

  StrokePainter(
    this.lines,
    this.currentLine, {
    this.clipPath,
    this.isSt0Completed = false,
    required this.groupedPaths,
    required this.strokeColor,
    required this.currentPathIndex,
    required this.completedPaths,
    required this.isPointerShown,
    this.scratchPercent = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (clipPath == null || clipPath!.isEmpty) return;

    // 1. 전체 배경 그리기
    for (int i = 0; i < clipPath!.length; i++) {
      if (!completedPaths.contains(i)) {
        final path = clipPath![i];
        final fillPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }
    }

    // 2. 사용자가 그린 선
    for (int i = 0; i < clipPath!.length; i++) {
      if (completedPaths.contains(i)) {
        final path = clipPath![i];

        final fillPaint = Paint()
          ..color = strokeColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        canvas.save();
        canvas.clipPath(path);

        final userPaint = Paint()
          ..color = strokeColor
          ..strokeWidth = 60.sp
          ..strokeCap = StrokeCap.round;

        for (var line in lines) {
          for (int j = 0; j < line.length - 1; j++) {
            if (path.contains(line[j]) && path.contains(line[j + 1])) {
              canvas.drawLine(line[j], line[j + 1], userPaint);
            }
          }
        }

        canvas.restore();
      }
    }

    // 3. 현재 진행 중인 path만 클립해서 선 그리기 (중간)
    if (!completedPaths.contains(currentPathIndex)) {
      final path = clipPath![currentPathIndex];

      canvas.save();
      canvas.clipPath(path);

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

      canvas.restore();
    }

    // 4. 가이드라인 (점선)
    if (isPointerShown) {
      final pathMetrics = clipPath![currentPathIndex].computeMetrics();
      final dotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      for (final metric in pathMetrics) {
        for (double t = 0; t < metric.length; t += 10.0) {
          final pos = metric.getTangentForOffset(t)?.position;
          if (pos != null) {
            canvas.drawCircle(pos, 3.0, dotPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
