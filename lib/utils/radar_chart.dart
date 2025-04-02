import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class RadarChartWidget extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final List<Color> gradientColors;
  final Function(int) onLabelTap;

  const RadarChartWidget({
    super.key,
    required this.values,
    required this.labels,
    required this.gradientColors,
    required this.onLabelTap,
  });

  @override
  _RadarChartWidgetState createState() => _RadarChartWidgetState();
}

class _RadarChartWidgetState extends State<RadarChartWidget> {
  int? selectedLabelIndex;
  Rect? tappedLabelRect;

  Rect calculateLabelRect(int i, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final int numSides = widget.values.length;
    final double maxRadius = min(centerX, centerY) - 20;

    double angle = (2 * pi * i / numSides) - (pi / 2);
    double radius = maxRadius;
    double x = centerX + radius * cos(angle);
    double y = centerY + radius * sin(angle);

    double xOffset = cos(angle) * 50;
    double yOffset = sin(angle) * 25;
    x += xOffset;
    y += yOffset;

    y += 50;
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.labels[i],
        style: const TextStyle(
          color: fontMain,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    Rect baseRect = Rect.fromCenter(
      center: Offset(x, y),
      width: textPainter.width,
      height: textPainter.height,
    );

    return baseRect.inflate(max(textPainter.width, textPainter.height) * 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final Size chartSize = Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.8);
      final Offset chartOffset = Offset(
        (constraints.maxWidth - chartSize.width) / 2,
        (constraints.maxHeight - chartSize.height) / 2,
      );

      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          final tapPosition = details.localPosition;
          final Offset localTapInChart = tapPosition;

          bool found = false;
          for (int i = 0; i < widget.values.length; i++) {
            Rect labelRect = calculateLabelRect(i, chartSize);
            if (labelRect.contains(localTapInChart)) {
              setState(() {
                selectedLabelIndex = i;
                tappedLabelRect = labelRect;
              });
              widget.onLabelTap(i);
              found = true;
              break;
            }
          }

          if (!found) {
            setState(() {
              selectedLabelIndex = null;
              tappedLabelRect = null;
            });
          }
        },
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 2.0),
          ),
          child: Stack(
            children: [
              Positioned(
                left: chartOffset.dx,
                top: chartOffset.dy,
                child: CustomPaint(
                  size: chartSize,
                  painter: RadarChartPainter(
                    values: widget.values,
                    labels: widget.labels,
                    gradientColors: widget.gradientColors,
                    tappedLabelRect: tappedLabelRect,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> gradientColors;
  final Rect? tappedLabelRect;

  RadarChartPainter({
    required this.values,
    required this.labels,
    required this.gradientColors,
    this.tappedLabelRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final int numSides = values.length;
    final double maxRadius = min(centerX, centerY) - 20;
    final double circleRadius = 3.0;

    final List<Color> dotColors = [
      const Color(0xFF2676B9),
      const Color(0xFFE2156D),
      const Color(0xFF005A17),
      const Color(0xFF653E90),
      const Color(0xFFEF7300),
    ];

    final Paint radarCirclePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    int gridLines = 5;
    for (int i = 1; i <= gridLines; i++) {
      double radius = (maxRadius / gridLines) * i;
      canvas.drawCircle(Offset(centerX, centerY), radius, radarCirclePaint);
    }

    Path radarPath = Path();
    for (int i = 0; i < numSides; i++) {
      double angle = (2 * pi * i / numSides) - (pi / 2);
      double radius = values[i] * maxRadius;
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);
      if (i == 0) {
        radarPath.moveTo(x, y);
      } else {
        radarPath.lineTo(x, y);
      }
    }
    radarPath.close();

    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(centerX, centerY),
        size.width / 2,
        gradientColors,
        const [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(radarPath, fillPaint);

    for (int i = 0; i < numSides; i++) {
      double angle = (2 * pi * i / numSides) - (pi / 2);
      Color dotColor = dotColors[i % dotColors.length];
      final Paint dotPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;
      for (int j = 1; j <= gridLines; j++) {
        double radius = (maxRadius / gridLines) * j;
        double xDot = centerX + radius * cos(angle);
        double yDot = centerY + radius * sin(angle);
        canvas.drawCircle(Offset(xDot, yDot), circleRadius, dotPaint);
      }
    }

    for (int i = 0; i < numSides; i++) {
      double angle = (2 * pi * i / numSides) - (pi / 2);
      double radius = maxRadius;
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);

      double xOffset = cos(angle) * 50;
      double yOffset = sin(angle) * 25;
      x += xOffset;
      y += yOffset;

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: fontMain,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      Offset textOffset = Offset(x - textPainter.width / 2, y - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }

    // if (tappedLabelRect != null) {
    //   final Paint borderPaint = Paint()
    //     ..color = Colors.red
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2.0;
    //   canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
    // }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.tappedLabelRect != tappedLabelRect ||
        oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.gradientColors != gradientColors;
  }
}
