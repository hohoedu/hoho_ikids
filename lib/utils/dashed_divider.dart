import 'package:flutter/material.dart';

Widget dashedDivider({
  double height = 1.0, // 점선의 두께
  Color color = const Color(0xFFDED6A9), // 점선의 색상
  double dashWidth = 5.0, // 점선의 길이
  double dashSpace = 3.0, // 점선 간격
}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final boxWidth = constraints.constrainWidth();
      final dashCount = (boxWidth / (dashWidth + dashSpace)).floor(); // 점선 개수
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dashCount, (_) {
          return SizedBox(
            width: dashWidth,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color),
            ),
          );
        }),
      );
    },
  );
}