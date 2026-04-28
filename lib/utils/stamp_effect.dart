import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/main.dart';

class StampEffect extends StatefulWidget {
  final int totalStars;
  final int collectedCount;

  const StampEffect({required this.totalStars, required this.collectedCount});

  @override
  State<StampEffect> createState() => _StarStampRowState();
}

class _StarStampRowState extends State<StampEffect> with SingleTickerProviderStateMixin {
  late AnimationController _stampController;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 위에서 쾅 찍히는 느낌
    _scaleAnim = Tween<double>(begin: 2.5, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.elasticOut),
    );

    // 살짝 기울어졌다 바로잡히는 느낌
    _rotateAnim = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOut),
    );

    // 다이얼로그 등장 후 살짝 딜레이 후 스탬프
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _stampController.forward();
    });
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.totalStars, (index) {
        final bool isCollected = index < widget.collectedCount;
        final bool isLastCollected = index == widget.collectedCount - 1;

        final Widget starImage = Image.asset(
          isCollected ? 'assets/images/star/before_star.png' : 'assets/images/star/gray_star.png',
          height: screenWidth > 1000 ? 50.h : 40.h,
        );

        if (isLastCollected) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedBuilder(
              animation: _stampController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                );
              },
              child: starImage,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: starImage,
        );
      }),
    );
  }
}
