import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/booki/booki_stroke_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/booki/booki_stroke/booki_stroke_widgets/booki_stroke_horizontal_word.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BookiStrokeHorizontalScreen extends StatefulWidget {
  final String keyCode;

  const BookiStrokeHorizontalScreen({super.key, required this.keyCode});

  @override
  State<BookiStrokeHorizontalScreen> createState() => _BookiStrokeHorizontalScreenState();
}

class _BookiStrokeHorizontalScreenState extends State<BookiStrokeHorizontalScreen> {
  final bgmController = Get.find<BgmController>();
  final strokeData = Get.find<BookiStrokeDataController>();
  final ValueNotifier<bool> resetNotifier = ValueNotifier(false);

  int currentIndex = 0;
  int totalCompletedIndex = 0;
  bool isDialogShown = false;
  bool isPointerShown = true;

  late AudioPlayer _audioPlayer;
  final Random random = Random();

  int strokeIndex = 0;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('booki_write');
    _audioPlayer = AudioPlayer();
    _updateNote();
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("Error playing sound: $e");
    }
  }

  void _updateNote() {
    setState(() {
      isPointerShown = true;
      getColorIndex();
    });
  }

  void _onNextWord() {
    setState(() {
      _onResetTracing();
      currentIndex = (currentIndex + 1) % strokeData.bookiStrokeDataList.length;
      _updateNote();
    });
  }

  void _onPrevWord() {
    setState(() {
      _onResetTracing();
      currentIndex = (currentIndex - 1 + strokeData.bookiStrokeDataList.length) % strokeData.bookiStrokeDataList.length;
      _updateNote();
    });
  }

  void _completeWord() async {
    setState(() {
      isPointerShown = false;
    });
    totalCompletedIndex++;
    _playSound(strokeData.bookiStrokeDataList[currentIndex].voicePath);

    if (totalCompletedIndex >= strokeData.bookiStrokeDataList.length) {
      starUpdateService('write', widget.keyCode);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isDialogShown = true;
        });
        _showCompletionDialog();
      });
    }
  }

  void _showCompletionDialog() async {
    lottieDialog(
      onReset: () async {
        setState(() {
          isPointerShown = true;
          totalCompletedIndex = 0;
          currentIndex = 0;
          _updateNote();
        });
        Get.back();
      },
      onMain: () async {
        if (Platform.isIOS) {
          await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
        } else {
          await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
        }
        Get.back();
        Get.back();
      },
    );
  }

  void getColorIndex() {
    setState(() {
      strokeIndex = random.nextInt(bookiStrokeColors.length);
    });
  }

  void _onResetTracing() {
    setState(() {
      isPointerShown = true;
    });
    getColorIndex();
    resetNotifier.value = !resetNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDE45D),
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        isContent: true,
        title: ' ',
        isPortraitMode: false,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: Column(
          children: [
            // 상단 진행 표시
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFFE7610B), fontSize: 28, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: '$totalCompletedIndex'),
                      TextSpan(
                        text: ' / ${strokeData.bookiStrokeDataList.length}',
                        style: const TextStyle(color: fontMain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 메인 캔버스
            Expanded(
              flex: 15,
              child: SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: ClipRect(
                        child: BookiStrokeHorizontalWord(
                          strokeController: strokeData,
                          currentIndex: currentIndex,
                          resetNotifier: resetNotifier,
                          onComplete: _completeWord,
                          isPointerShown: isPointerShown,
                          strokeColor: bookiStrokeColors[strokeIndex],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _onPrevWord,
                                child: currentIndex > 0
                                    ? const Icon(Icons.skip_previous, size: 46, color: fontWhite)
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Logger().d('클릭');
                                  _onResetTracing();
                                },
                                child: const Icon(Icons.refresh, size: 46, color: fontWhite),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Logger().d('넥스트 버튼');
                                  _onNextWord();
                                },
                                child: (strokeData.bookiStrokeDataList.length - 1) > currentIndex
                                    ? const Icon(Icons.skip_next, size: 46, color: fontWhite)
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
