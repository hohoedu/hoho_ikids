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

class MissionProgress extends StatefulWidget {
  final int totalCount;
  final int completedCount;
  final String completedAsset;

  const MissionProgress({
    super.key,
    required this.totalCount,
    required this.completedCount,
    required this.completedAsset,
  });

  @override
  State<MissionProgress> createState() => _MissionProgressState();
}

class _MissionProgressState extends State<MissionProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotationAnim;

  int _animatingIndex = -1; // 현재 꽝 찍히는 인덱스 (-1 = 없음)

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // 위에서 쾅! 내려찍는 느낌: 크게 → 작게 → 약간 튕김
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.7, end: 0.85).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.05).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _rotationAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: -0.08, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 40,
      ),
    ]).animate(_controller);

    // 렌더링 완료 후 순차 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stampSequentially(0);
    });
  }

  Future<void> _stampSequentially(int index) async {
    if (!mounted) return;
    if (index >= widget.completedCount) return; // 완료된 것만 찍음

    setState(() => _animatingIndex = index);
    HapticFeedback.mediumImpact(); // 꽝! 햅틱

    _controller.reset();
    await _controller.forward();

    if (!mounted) return;

    // 다음 도장까지 잠깐 대기
    await Future.delayed(const Duration(milliseconds: 180));
    _stampSequentially(index + 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth / 5;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.totalCount, (i) {
            final isDone = i < widget.completedCount;
            final isAnimating = i == _animatingIndex;
            // 아직 애니메이션 차례가 안 온 완료 도장은 숨김
            final isRevealedDone = isDone && i < _animatingIndex;

            if (isAnimating) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnim.value,
                    child: Opacity(
                      opacity: _opacityAnim.value,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  widget.completedAsset,
                  height: imageSize,
                  width: imageSize,
                ),
              );
            }

            if (isRevealedDone) {
              return Image.asset(
                widget.completedAsset,
                height: imageSize,
                width: imageSize,
              );
            }

            // 아직 안 찍혔거나 미완료
            return Image.asset(
              'assets/images/mission/lock_gray.png',
              height: imageSize,
              width: imageSize,
            );
          }),
        );
      },
    );
  }
}
