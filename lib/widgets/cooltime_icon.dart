import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/utils/cooltime_dialog_content.dart';
import 'package:hani_booki/utils/cooltime_utils.dart';

class CooltimeIcon extends StatefulWidget {
  final String lastTime;

  const CooltimeIcon({super.key, required this.lastTime});

  @override
  State<CooltimeIcon> createState() => _CooltimeIconState();
}

class _CooltimeIconState extends State<CooltimeIcon> {
  StreamSubscription<int>? _sub;
  String _remaining = '';
  double _progress = 1.0; // 1.0 = 쿨타임 시작, 0.0 = 완료

  static const totalSeconds = 5 * 60;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _sub = GlobalTicker.stream.listen((_) => _updateRemaining());
  }

  void _updateRemaining() {
    final lastTime = widget.lastTime;
    if (lastTime.isEmpty) return;
    try {
      final last = DateTime(
        int.parse(lastTime.substring(0, 4)),
        int.parse(lastTime.substring(4, 6)),
        int.parse(lastTime.substring(6, 8)),
        int.parse(lastTime.substring(8, 10)),
        int.parse(lastTime.substring(10, 12)),
        lastTime.length >= 14 ? int.parse(lastTime.substring(12, 14)) : 0,
      );
      final elapsed = DateTime.now().difference(last);
      final remaining = const Duration(minutes: 5) - elapsed;

      if (remaining.isNegative) {
        _sub?.cancel();
        if (mounted) {
          setState(() {
            _remaining = '';
            _progress = 0.0;
          });
        }
      } else {
        final m = remaining.inMinutes;
        final s = remaining.inSeconds % 60;
        if (mounted) {
          setState(() {
            _remaining = '$m:${s.toString().padLeft(2, '0')}';
            _progress = remaining.inSeconds / totalSeconds;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Get.defaultDialog(
          barrierDismissible: true,
          backgroundColor: Colors.white,
          title: '별 포인트 충전 중!',
          content: CooltimeDialogContent(lastTime: widget.lastTime),
          buttonColor: Colors.green,
          textConfirm: '확인',
          onConfirm: () => Get.back(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/icons/cooltime.png', fit: BoxFit.fill),
                  ),
                ),
                CustomPaint(
                  size: Size(22.w, 22.w),
                  painter: _CooltimePainter(progress: _progress),
                ),
                // Text(
                //   _remaining,
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 6.sp,
                //     shadows: [
                //       Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
                //     ],
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _CooltimePainter extends CustomPainter {
  final double progress; // 1.0 → 0.0

  _CooltimePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final startAngle = -pi / 2 + 2 * pi * (1 - progress);
    final sweepAngle = 2 * pi * progress;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();

    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    ));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CooltimePainter oldDelegate) => oldDelegate.progress != progress;
}
