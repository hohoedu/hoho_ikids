import 'package:flutter/material.dart';

class BookiStrokeHorizontalPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> currentLine;
  final List<Path>? clipPath;
  final List<Path> guideStrokePaths;
  final int currentPathIndex;
  final Set<int> completedPaths;
  final bool isPointerShown;
  final double scratchPercent;
  final Color strokeColor;

  BookiStrokeHorizontalPainter({
    required this.lines,
    required this.currentLine,
    required this.clipPath,
    required this.guideStrokePaths,
    required this.currentPathIndex,
    required this.completedPaths,
    required this.isPointerShown,
    required this.scratchPercent,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (clipPath == null || clipPath!.isEmpty) return;

    // 1) 아직 완료되지 않은 path는 흰색 바탕
    for (int i = 0; i < clipPath!.length; i++) {
      final path = clipPath![i];
      final fill = Paint()..style = PaintingStyle.fill;

      if (completedPaths.contains(i)) {
        fill.color = strokeColor;
      } else {
        fill.color = Colors.white;
      }
      canvas.drawPath(path, fill);
    }

    // 2) 현재 진행 중인 path에만 클립 후 사용자 선 그리기
    if (!completedPaths.contains(currentPathIndex)) {
      final path = clipPath![currentPathIndex];
      canvas.save();
      canvas.clipPath(path);

      final userPaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 56
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (final line in lines) {
        for (int i = 0; i < line.length - 1; i++) {
          canvas.drawLine(line[i], line[i + 1], userPaint);
        }
      }

      for (int i = 0; i < currentLine.length - 1; i++) {
        canvas.drawLine(currentLine[i], currentLine[i + 1], userPaint);
      }
      canvas.restore();
    }

    if (isPointerShown && currentPathIndex < clipPath!.length) {
      final dotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      final metrics = clipPath![currentPathIndex].computeMetrics();
      for (final metric in metrics) {
        for (double t = 0; t < metric.length; t += 10.0) {
          final pos = metric.getTangentForOffset(t)?.position;
          if (pos != null) canvas.drawCircle(pos, 3.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BookiStrokeHorizontalPainter old) {
    return old.lines != lines ||
        old.currentLine != currentLine ||
        old.clipPath != clipPath ||
        old.completedPaths != completedPaths ||
        old.currentPathIndex != currentPathIndex ||
        old.scratchPercent != scratchPercent ||
        old.isPointerShown != isPointerShown ||
        old.strokeColor != strokeColor;
  }
}
