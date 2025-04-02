import 'package:flutter/material.dart';

class BubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double borderRadius = 10;
    const double arrowWidth = 5;

    // 왼쪽 모서리
    path.moveTo(0, 0);

    // 오른쪽 상단 모서리
    path.lineTo(size.width - arrowWidth - borderRadius, 0);

    // 오른쪽 상단 모서리 라운드
    path.quadraticBezierTo(
      size.width - arrowWidth,
      0,
      size.width - arrowWidth,
      borderRadius,
    );

    //
    path.lineTo(size.width - arrowWidth, size.height * 0.4);

    path.lineTo(size.width, size.height * 0.5);

    path.lineTo(size.width - arrowWidth, size.height * 0.6);

    path.lineTo(size.width - arrowWidth, size.height - borderRadius);

    path.quadraticBezierTo(
      size.width - arrowWidth,
      size.height,
      size.width - arrowWidth - borderRadius,
      size.height,
    );

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
