import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/utils/cooltime_utils.dart';

class CooltimeDialogContent extends StatefulWidget {
  final String lastTime;

  const CooltimeDialogContent({super.key, required this.lastTime});

  @override
  State<CooltimeDialogContent> createState() => _CooltimeDialogContentState();
}

class _CooltimeDialogContentState extends State<CooltimeDialogContent> {
  StreamSubscription<int>? _sub;
  String _remaining = '';

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
      final remaining = const Duration(minutes: 5) - DateTime.now().difference(last);
      if (remaining.isNegative) {
        _sub?.cancel();
        if (mounted) {
          setState(() => _remaining = '');
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        }
      } else {
        final m = remaining.inMinutes;
        final s = remaining.inSeconds % 60;
        if (mounted) setState(() => _remaining = '$m:${s.toString().padLeft(2, '0')}');
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

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '잠시 후 다시 획득할 수 있어요!\n남은 시간: ',
            style: TextStyle(color: fontSub, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: _remaining,
            style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}