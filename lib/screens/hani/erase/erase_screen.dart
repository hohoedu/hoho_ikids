import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/hani/hani_erase_data.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:scratcher/scratcher.dart';

class EraseScreen extends StatefulWidget {
  final String keyCode;

  const EraseScreen({super.key, required this.keyCode});

  @override
  State<EraseScreen> createState() => _EraseScreenState();
}

class _EraseScreenState extends State<EraseScreen> {
  final bgmController = Get.find<BgmController>();
  final eraseData = Get.find<HaniEraseDataController>();
  bool _isScratched = false;
  final random = Random();

  List<List<HaniEraseData>> remainingGroups = [];
  List<HaniEraseData> currentGroup = [];
  int currentIndex = 0;
  Key _scratcherKey = UniqueKey();
  late AudioPlayer _audioPlayer;

  double _scratchPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('clean');
    _audioPlayer = AudioPlayer();
    remainingGroups = List.from(eraseData.getGroupedData());
    getRandomGroup();
  }

  Future<void> _playSoundAndTransition(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      await _audioPlayer.processingStateStream
          .firstWhere((state) => state == ProcessingState.completed);
    } catch (e) {
      Logger().e('음성 재생 중 오류 발생: $e');
    }
    await nextScratcher();
  }

  void getRandomGroup() {
    if (remainingGroups.isEmpty) {
      Logger().e("오류: remainingGroups가 비어 있습니다! 무작위 그룹을 가져올 수 없습니다.");
      return;
    }

    int groupIndex = random.nextInt(remainingGroups.length);
    currentGroup = remainingGroups[groupIndex];
    remainingGroups.removeAt(groupIndex);

    if (currentGroup.isNotEmpty) {
      currentIndex = random.nextInt(currentGroup.length);
    } else {
      Logger().e("오류: currentGroup이 비어 있습니다! 유효한 이미지가 없습니다.");
      getRandomGroup();
    }
  }

  Future<void> nextScratcher() async {
    if (remainingGroups.isEmpty) {
      await Future.delayed(Duration(milliseconds: 300));
      await starUpdateService('clean', widget.keyCode);
      lottieDialog(
        onMain: () {
          Get.back();
          Get.back();
        },
        onReset: () {
          Get.back();
          setState(() {
            remainingGroups = List.from(eraseData.getGroupedData());
            if (remainingGroups.isNotEmpty) {
              _isScratched = false;
              _scratcherKey = UniqueKey();
              getRandomGroup();
            } else {
              Logger().e("오류: 리셋 후 remainingGroups가 비어 있습니다.");
            }
          });
        },
      );
      return;
    }

    getRandomGroup();
    try {
      await precacheImage(
        NetworkImage(currentGroup[currentIndex].imagePath),
        context,
      );
    } catch (e) {
      Logger().e("이미지 로딩 중 오류 발생: $e");
    }

    setState(() {
      _isScratched = false;
      _scratcherKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: mBackWhite,
      appBar: MainAppBar(
        title: ' ',
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Scratcher(
              key: _scratcherKey,
              brushSize: 30.sp,
              threshold: 80,
              onChange: (value) {
                setState(() {
                  _scratchPercentage = value;
                });
                if (value >= 80 && !_isScratched) {
                  setState(() {
                    _isScratched = true;
                  });
                  _playSoundAndTransition(currentGroup[currentIndex].voicePath);
                }
              },
              onThreshold: () async {
                if (!_isScratched) {
                  setState(() {
                    _isScratched = true;
                  });
                  _playSoundAndTransition(currentGroup[currentIndex].voicePath);
                }
              },
              color: Colors.transparent,
              image: _isScratched
                  ? null
                  : Image.asset(
                      'assets/images/hani/erase_front.png',
                      fit: BoxFit.contain,
                    ),
              child: currentGroup.isNotEmpty
                  ? Image.network(
                      currentGroup[currentIndex].imagePath,
                      fit: BoxFit.contain,
                    )
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    bgmController.stopBgm();
    super.dispose();
  }
}
