import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/bubble_data.dart';

class KidokBubble extends StatefulWidget {
  const KidokBubble({super.key, required this.bubbleData});

  final List<BubbleData> bubbleData;

  @override
  State<KidokBubble> createState() => _KidokBubbleState();
}

class _KidokBubbleState extends State<KidokBubble> {
  bool hasInitialized = false;

  @override
  void didUpdateWidget(covariant KidokBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bubbleData != oldWidget.bubbleData) {
      hasInitialized = false;
    }
  }

  void computePackedPositions(List<BubbleData> bubbles, Size canvasSize) {
    // final allMax = bubbles.every((b) => b.value == 100.0);

    // if (allMax) {
    //   final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    //   final radius = min(canvasSize.width, canvasSize.height) * 0.4;
    //   final angles = [30, 90, 150, 210, 270, 330];
    //
    //   for (int i = 0; i < bubbles.length; i++) {
    //     final rad = angles[i] * pi / 180;
    //     bubbles[i].position = Offset(
    //       center.dx + radius * sin(rad),
    //       center.dy - radius * cos(rad),
    //     );
    //   }
    //   return;
    // }
    final random = Random();
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    for (final b in bubbles) {
      final dx = (random.nextDouble() - 0.5) * canvasSize.width * 0.5;
      final dy = (random.nextDouble() - 0.5) * canvasSize.height * 0.5;
      b.position = center + Offset(dx, dy);
    }

    const int iterations = 500;
    const double margin = 8.0;

    for (int iter = 0; iter < iterations; iter++) {
      for (int i = 0; i < bubbles.length; i++) {
        for (int j = i + 1; j < bubbles.length; j++) {
          final a = bubbles[i];
          final b = bubbles[j];
          final delta = a.position - b.position;
          final dist = delta.distance;
          final minDist = a.radius + b.radius + margin;

          if (dist < minDist && dist > 0) {
            final push = (minDist - dist) / 2;
            final dir = delta / dist;
            a.position += dir * push;
            b.position -= dir * push;
          }
        }

        final b = bubbles[i];
        b.position = Offset(
          b.position.dx.clamp(b.radius + margin, canvasSize.width - b.radius - margin),
          b.position.dy.clamp(b.radius + margin, canvasSize.height - b.radius - margin),
        );
      }
    }
  }

  Widget buildBubbleChart(List<BubbleData> data, Size size) {
    return Stack(
      children: data.map((b) {
        return Positioned(
          left: b.position.dx - b.radius,
          top: b.position.dy - b.radius,
          child: Container(
            width: b.radius * 2,
            height: b.radius * 2,
            decoration: BoxDecoration(
              color: b.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${b.label}\n${b.value.toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: b.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 1000;
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: isTablet ? 0 : 12.0),
            child: Text(
              '6개 영역 이해 분포',
              style: TextStyle(fontSize: 7.sp, fontFamily: 'BMJUA', color: Color(0xFF968B52)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      if (!hasInitialized) {
                        computePackedPositions(widget.bubbleData, size);
                        hasInitialized = true;
                      }
                      return buildBubbleChart(widget.bubbleData, size);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
