import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/mission/mission_clear_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/mission/mission_button.dart';
import 'package:hani_booki/widgets/mission/mission_progress.dart';
import 'package:logger/logger.dart';

class MissionCard extends StatefulWidget {
  final MissionInfo mission;
  final int index;
  final String keycode;

  const MissionCard({super.key, required this.mission, required this.index, required this.keycode});

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> with SingleTickerProviderStateMixin {
  late int _localCompleted;

  bool get _isAttendance => widget.index == 0;

  bool get _isAllDone => _localCompleted >= widget.mission.totalCount;

  @override
  void initState() {
    super.initState();
    _localCompleted = widget.mission.currentCount;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onStarRewardTap() async {
    Logger().d(widget.keycode);
    final missionNum = _isAttendance ? 1 : 2;
    // await missionClearService(missionNum, widget.keycode);
    await missionClearDialog(missionNum);
  }

  @override
  Widget build(BuildContext context) {
    final style = missionStyles[widget.index];
    final missionController = Get.find<MissionController>();

    return Obx(
      () {
        final isCleared = _isAttendance ? missionController.attendanceCleared.value : missionController.contentCleared.value;

        String footerText;
        VoidCallback? onTap;

        if (isCleared) {
          footerText = '미션 완료!!';
          onTap = null;
        } else if (_isAllDone) {
          footerText = '미션 성공! ⭐ ${widget.mission.missionStar}포인트 받기';
          onTap = _onStarRewardTap;
        } else {
          footerText = '미션 성공시 ${widget.mission.missionStar}포인트 획득!';
          onTap = null;
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: style['cardColor'] as Color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            style['label'] as String,
                            style: TextStyle(
                              fontSize: 6.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: style['labelColor'] as Color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            widget.mission.missionName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: MissionProgress(
                              totalCount: widget.mission.totalCount,
                              completedCount: _localCompleted,
                              completedAsset: style['completedAsset'] as String,
                              isCleared: isCleared,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: style['footerColor'] as Color,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                      ),
                      child: Text(
                        footerText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isCleared)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            if (isCleared)
              Positioned(
                child: Center(
                  child: Image.asset(
                    style['clearAsset'] as String,
                    scale: screenWidth > 1000 ? 5.5 : 9,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
