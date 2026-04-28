import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/services/auth/star_save_service.dart';
import 'package:hani_booki/services/auth/star_status_service.dart';
import 'package:hive/hive.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/widgets/dialog.dart';

class StarItem {
  final int id;
  final double x;
  final double y;
  final double rotation;
  final AnimationController controller;

  StarItem({required this.id, required this.x, required this.y, required this.rotation, required this.controller});
}

mixin StarEventMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  final Random _starRandom = Random();
  final List<StarItem> activeStars = [];
  Timer? _starSpawnTimer;

  late String _starBtype;
  late String _starHosu;
  late String _starGb;
  late String _starContentId;
  String? _starIdate;

  bool isStarDialogOpen = false;

  Future<void> initStarEventFromServer({required String btype, required String hosu, required String gb}) async {
    _starBtype = btype;
    _starHosu = hosu;
    _starGb = gb;
    _starContentId = btype + gb + hosu;



    final status = await starStatusService(btype: btype, hosu: hosu, gb: gb);

    if (status == null) {
      return;
    }

    _starIdate = status['idate'];
    final int remainCnt = status['remain_cnt'];

    if (remainCnt <= 0) {
      return;
    }

    final bool alreadyDone = await _isStarDoneToday();

    if (alreadyDone) {
      return;
    }

    _scheduleNextStar(isFirst: true);
  }

  void disposeStarEvent() {
    _starSpawnTimer?.cancel();
    for (final star in activeStars) {
      star.controller.dispose();
    }
    activeStars.clear();
  }

  List<Widget> buildStarWidgets() {
    return activeStars.map((star) {
      return Positioned(
        left: star.x,
        top: star.y,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: star.controller,
            curve: Curves.elasticOut,
          ),
          child: Transform.rotate(
            angle: star.rotation,
            child: GestureDetector(
              onTap: () => _onStarTapped(star),
              child: Image.asset(
                'assets/images/star/before_star.png',
                width: 200.h,
                height: 200.h,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ─────────────────────────────────────────
  // HIVE (콘텐츠 중복 방지)
  // ─────────────────────────────────────────

  Future<bool> _isStarDoneToday() async {
    if (_starIdate == null || _starIdate!.isEmpty) {
      return true;
    }
    final userdata = Get.find<UserDataController>();
    final box = Hive.box('settings');
    final key = 'star_done_${userdata.userData!.id}_${_starBtype}_${_starHosu}_$_starIdate';
    final List<String> doneList = List<String>.from(box.get(key, defaultValue: []));
    final bool done = doneList.contains(_starContentId);
    return done;
  }

  Future<void> _markStarDone() async {
    if (_starIdate == null) return;
    final userdata = Get.find<UserDataController>();
    final box = Hive.box('settings');
    final key = 'star_done_${userdata.userData!.id}_${_starBtype}_${_starHosu}_$_starIdate';
    final List<String> doneList = List<String>.from(box.get(key, defaultValue: []));
    if (!doneList.contains(_starContentId)) {
      doneList.add(_starContentId);
      await box.put(key, doneList);
    }
  }

  // ─────────────────────────────────────────
  // SCHEDULE
  // ─────────────────────────────────────────

  void _scheduleNextStar({bool isFirst = false}) {
    if (!mounted) return;

    _starSpawnTimer?.cancel();

    final int delaySeconds = isFirst ? _starRandom.nextInt(1) : 120 + _starRandom.nextInt(180);

    _starSpawnTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (!mounted) return;

      final status = await starStatusService(
        btype: _starBtype,
        hosu: _starHosu,
        gb: _starGb,
      );

      if (status == null || !mounted) return;

      final int remainCnt = status['remain_cnt'];

      if (remainCnt <= 0) {
        return;
      }

      final bool alreadyDone = await _isStarDoneToday();
      if (alreadyDone) {
        return;
      }

      final double roll = _starRandom.nextDouble();
      final bool pass = roll < 0.6;
      pass ? _spawnStar() : _scheduleNextStar();
    });
  }

  // ─────────────────────────────────────────
  // SPAWN / REMOVE
  // ─────────────────────────────────────────

  void _spawnStar() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final double x = 60 + _starRandom.nextDouble() * (size.width - 120);
    final double y = 80 + _starRandom.nextDouble() * (size.height - 200);
    final double rotation = (_starRandom.nextDouble() - 0.5) * (pi / 3);

    final star = StarItem(
      id: DateTime.now().millisecondsSinceEpoch,
      x: x,
      y: y,
      rotation: rotation,
      controller: controller,
    );

    setState(() => activeStars.add(star));
    controller.forward();
  }

  void _removeStar(int id) {
    if (!mounted) return;
    setState(() {
      final star = activeStars.where((s) => s.id == id).firstOrNull;
      if (star != null) {
        activeStars.remove(star);
        star.controller.dispose();
      }
    });
  }

  // ─────────────────────────────────────────
  // COLLECT
  // ─────────────────────────────────────────

  Future<void> _onStarTapped(StarItem star) async {
    _removeStar(star.id);


    await starSaveService(
      btype: _starBtype,
      hosu: _starHosu,
      gb: _starGb,
    );

    final result = await starStatusService(btype: _starBtype, hosu: _starHosu, gb: _starGb);
    if (result == null) {
      _scheduleNextStar();
      return;
    }

    final int remainCnt = result['remain_cnt']!;
    final int currentCnt = result['current_cnt']!;

    await _markStarDone();

    final box = Hive.box('settings');
    await box.put('star_count', remainCnt.clamp(0, 99));

    isStarDialogOpen = true;

    if (_starGb == 'write') {
      await findVerticalStarDialog(remainCnt: remainCnt, currentCnt: currentCnt);
    } else {
      await findStarDialog(remainCnt: remainCnt, currentCnt: currentCnt);
    }

    isStarDialogOpen = false;

    _scheduleNextStar();
  }
}
