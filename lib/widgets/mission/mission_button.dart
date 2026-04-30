import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/mission/mission_card.dart';

class MissionButton extends StatefulWidget {
  final String keycode;

  const MissionButton({super.key, required this.keycode});

  @override
  State<MissionButton> createState() => _MissionButtonState();
}

class _MissionButtonState extends State<MissionButton> with TickerProviderStateMixin {
  late AnimationController _swingController;
  late Animation<double> _swingAnim;

  @override
  void initState() {
    super.initState();

    _swingController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _swingAnim = Tween(begin: -0.26, end: 0.26).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: false,
        isScrollControlled: true,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        builder: (_) => MissionBottomSheet(keycode: widget.keycode),
      ),
      child: Align(
        alignment: AlignmentGeometry.center,
        child: SizedBox(
          height: screenWidth > 1000 ? 105.h : 90.h,
          child: AnimatedBuilder(
            animation: _swingAnim,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.rotationZ(_swingAnim.value),
                child: child,
              );
            },
            child: Image.asset('assets/images/star/mission_star.png'),
          ),
        ),
      ),
    );
  }
}

class MissionBottomSheet extends StatelessWidget {
  final String keycode;

  const MissionBottomSheet({super.key, required this.keycode});

  String _formatExpiredAt(String expiredAt) {
    try {
      final expiry = DateTime.parse(expiredAt.replaceAll(' ', 'T'));
      final diff = expiry.difference(DateTime.now());
      if (diff.isNegative) return '미션이 종료되었습니다.';
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      final minutes = diff.inMinutes % 60;
      return '$days일 $hours시간 $minutes분 남음';
    } catch (_) {
      return expiredAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MissionController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final sheetHeight = screenWidth > 1000 ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: sheetHeight,
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Obx(() {
        final missionData = controller.missionData.value;

        if (missionData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isEmpty = missionData.attendanceMission.missionNumber.isEmpty && missionData.contentMission.missionNumber.isEmpty;
        if (isEmpty) {
          return Column(
            children: [
              MissionHeader(
                keycode: keycode,
                onClose: () => Navigator.pop(context),
                showTitle: false,
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    '미션을 준비 중입니다.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        final missions = [
          missionData.attendanceMission,
          missionData.contentMission,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MissionHeader(keycode: keycode, onClose: () => Navigator.pop(context)),
            const SizedBox(height: 8),
            _MissionTimerBadge(label: _formatExpiredAt(missionData.expiredAt)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: missions
                      .asMap()
                      .entries
                      .map(
                        (entry) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: MissionCard(
                              mission: entry.value,
                              index: entry.key,
                              keycode: keycode,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Text(
              '※ 연속 미션은 하루라도 놓치면 처음부터 다시 시작돼요!',
              style: TextStyle(color: Color(0xFFABABAB)),
            ),
          ],
        );
      }),
    );
  }
}

class MissionHeader extends StatelessWidget {
  final String keycode;
  final VoidCallback onClose;
  final bool showTitle;

  const MissionHeader({
    super.key,
    required this.keycode,
    required this.onClose,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        if (showTitle)
          Expanded(
            flex: 10,
            child: Text(
              '${int.tryParse(keycode.substring(2, 4)).toString()}호 미션을 완료하고 별 포인트를 획득해봐요!!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
          ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: onClose,
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset('assets/images/rank/rank_cancel.png', scale: 6),
            ),
          ),
        ),
      ],
    );
  }
}

class _MissionTimerBadge extends StatelessWidget {
  final String label;

  const _MissionTimerBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

