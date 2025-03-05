import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final Color fillColor;
  final double fontSize;
  final Color outlineColor;
  final double outlineWidth;

  OutlinedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.outlineWidth,
    this.fillColor = Colors.black,
    this.outlineColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 흰색 외곽선
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cookie',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..strokeJoin = StrokeJoin.round  // 곡선 부분을 부드럽게 처리
              ..strokeCap = StrokeCap.round
              ..color = outlineColor,
          ),
        ),
        // 내부 텍스트
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: fillColor,
            fontFamily: 'Cookie'
          ),
        ),
      ],
    );
  }
}
