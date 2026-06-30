import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_puzzle_data.dart';
import 'package:hani_booki/services/hani/hani_content_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/utils/star_event_mixin.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class PuzzleScreen extends StatefulWidget {
  final String keyCode;
  final String lastTime;

  const PuzzleScreen({super.key, required this.keyCode, required this.lastTime});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin, StarEventMixin<PuzzleScreen> {
  final bgmController = Get.find<BgmController>();
  final haniPuzzleDataController = Get.find<HaniPuzzleDataController>();

  bool isGameActive = true;

  final List<String> selectedQuiz = [];
  final List<int> selectedIndexes = [];
  late final List<bool> visibilityStatus;
  late final List<String> randomPath;
  late AudioPlayer _audioPlayer;
  late List<String> selectedVoicePaths = [];

  double progress = 1.5;
  final int timeLimit = 30;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('puzzle');
    _audioPlayer = AudioPlayer();
    final allPaths = <String>[
      for (var item in haniPuzzleDataController.haniPuzzleDataList) ...[item.form, item.sound, item.mean]
    ];
    randomPath = List.of(allPaths)..shuffle();
    visibilityStatus = List.filled(randomPath.length, true);
    startTimer();
    initStarEventFromServer(btype: 'H', hosu: widget.keyCode.substring(2, 4), gb: 'puz');
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e('Error playing sound: $e');
    }
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (activeStars.isNotEmpty || isStarDialogOpen) return;

        setState(
          () {
            progress = (progress - 1.0 / (timeLimit * 20)).clamp(0.0, 1.0);
            if (progress <= 0) {
              timer.cancel();
              disposeStarEvent();
              oneButtonDialog(
                title: '시간초과',
                content: '시간이 종료되었습니다\n 다시 시도해 보세요!',
                onTap: () {
                  Get.back();
                  resetGame();
                },
                buttonText: '다시 시작',
              );
            }
          },
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      progress = 1.0;
      selectedQuiz.clear();
      selectedIndexes.clear();
      visibilityStatus.fillRange(0, visibilityStatus.length, true);
      randomPath.shuffle();
      isGameActive = true;
      startTimer();
    });
  }

  Future<void> checkSelection() async {
    if (selectedQuiz.length == 3) {
      final isCorrect = haniPuzzleDataController.haniPuzzleDataList.any(
        (item) => selectedQuiz.contains(item.form) && selectedQuiz.contains(item.sound) && selectedQuiz.contains(item.mean),
      );

      if (isCorrect) {
        _playSound(selectedVoicePaths.first);
        setState(() {
          selectedVoicePaths = [];
          for (int i = 0; i < randomPath.length; i++) {
            if (selectedQuiz.contains(randomPath[i])) {
              visibilityStatus[i] = false;
            }
          }
        });
        if (visibilityStatus.every((isVisible) => !isVisible)) {
          timer.cancel();
          isGameActive = false;
          final starResult = await starUpdateService('puz', widget.keyCode);
          final result = await missionSaveService(missionNum: 2, gb: 'puz', keycode: widget.keyCode);

          if (result.success) {
            await showStampDialog(widget.keyCode);
          }
          if (starResult == '0000') {
            lottieDialog(
              onMain: () {
                Get.back();
                final userData = Get.find<UserDataController>();
                haniContentService(widget.keyCode, userData.userData!.id, userData.userData!.year);
              },
              onReset: () {
                Get.back();
                resetGame();
              },
            );
          } else if (starResult == '8888') {
            cooltimeDialog(
              lastTime: widget.lastTime,
              onMain: () {
                Get.back();
                final userData = Get.find<UserDataController>();
                haniContentService(widget.keyCode, userData.userData!.id, userData.userData!.year);
              },
              onReset: () {
                Get.back();
                resetGame();
              },
            );
          }
        }
      } else {
        await SoundManager.playNo();
        setState(() {
          selectedVoicePaths = [];
        });
      }

      setState(() {
        selectedQuiz.clear();
        selectedIndexes.clear();
        selectedVoicePaths = [];
      });
    }
  }

  double getProgress() {
    final hiddenCount = visibilityStatus.where((isVisible) => !isVisible).length;
    return hiddenCount / randomPath.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        isContent: true,
        title: ' ',
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/hani/hani_puzzle_bg.png',
                  ),
                  fit: BoxFit.fill),
            ),
            child: Center(
              child: SizedBox(
                width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final progressBarWidth = constraints.maxWidth;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: progress * progressBarWidth - 10,
                                  top: -20,
                                  child: Image.asset(
                                    'assets/images/icons/bomb.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double itemHeight = constraints.maxHeight / 3;
                            double itemWidth = constraints.maxWidth / (randomPath.length / 3);
                            return Stack(
                              children: [
                                // SizedBox(
                                //   width: double.infinity,
                                //   child: Opacity(
                                //     opacity: isGameActive ? 0.5 : 1,
                                //     child: ClipRRect(
                                //       borderRadius: BorderRadius.circular(25),
                                //       child: Image.network(
                                //         haniPuzzleDataController
                                //             .haniPuzzleDataList[0].backImage,
                                //         fit: BoxFit.fill,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                GridView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: (randomPath.length / 3).toInt(),
                                    childAspectRatio: itemWidth / itemHeight,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                  ),
                                  itemCount: randomPath.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final path = randomPath[index];
                                    final isSelected = selectedIndexes.contains(index);

                                    return Visibility(
                                      visible: visibilityStatus[index],
                                      child: GestureDetector(
                                        onTap: () async {
                                          await SoundManager.playClick();
                                          if (!selectedQuiz.contains(path)) {
                                            setState(() {
                                              selectedQuiz.add(path);
                                              selectedIndexes.add(index);

                                              final matchedItem = haniPuzzleDataController.haniPuzzleDataList.firstWhere(
                                                (item) => item.form == path || item.sound == path || item.mean == path,
                                                orElse: () => haniPuzzleDataController.haniPuzzleDataList[0], // 기본값
                                              );

                                              // 🎵 해당 단어의 voicePath를 리스트에 추가
                                              selectedVoicePaths.add(matchedItem.voicePath);

                                              checkSelection();
                                            });
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Image.network(
                                                path,
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                child: Center(
                                                  child: Icon(
                                                    Icons.circle_outlined,
                                                    size: 35.sp,
                                                    color: Colors.greenAccent,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...buildStarWidgets(widget.keyCode),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    disposeStarEvent();
    super.dispose();
  }
}
