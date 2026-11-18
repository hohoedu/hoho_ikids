import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _countUp = Duration(milliseconds: 1200);
const _starStep = Duration(milliseconds: 300);
const _hold = Duration(milliseconds: 1200);

/// 게임이 끝나면 점수를 0부터 세어 올리고 별을 하나씩 켠 뒤 저절로 닫힘.
/// 닫힌 다음 lottieDialog를 띄우면 됨. [stars]가 null이면 별 줄은 안 보임.
Future<void> showScoreSummary({required int score, int? stars, int maxStars = 5}) async {
  Get.generalDialog(
    barrierDismissible: false,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, __) => PopScope(
      canPop: false,
      child: _ScoreSummary(score: score, stars: stars, maxStars: maxStars),
    ),
  );
  await Future.delayed(_countUp + _starStep * (stars == null ? 0 : maxStars) + _hold);
  Get.back();
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({required this.score, required this.stars, required this.maxStars});

  final int score;
  final int? stars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final stars = this.stars;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: h * 0.1, vertical: h * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(h * 0.05),
            border: Border.all(color: const Color(0xFFFFD54F), width: h * 0.012),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('최종 점수', style: TextStyle(fontFamily: 'BMJUA', fontSize: h * 0.06, color: const Color(0xFF6D4C41))),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score.toDouble()),
                duration: _countUp,
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text(
                  '${NumberFormat('#,###').format(v.round())}점',
                  style: TextStyle(fontFamily: 'BMJUA', fontSize: h * 0.13, color: const Color(0xFFFF8A1F)),
                ),
              ),
              if (stars != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < maxStars; i++)
                      // 점수가 다 올라간 뒤 하나씩 켜짐
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: _countUp + _starStep * (i + 1),
                        builder: (_, v, __) {
                          final on = i < stars && v >= 1;
                          return AnimatedScale(
                            scale: on ? 1.15 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.star_rounded,
                                size: h * 0.12, color: on ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0)),
                          );
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
