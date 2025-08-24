import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/booki/booki_stroke_data.dart';
import 'package:hani_booki/_data/hani/hani_stroke_data.dart';
import 'package:hani_booki/screens/booki/booki_stroke/booki_stroke_widgets/booki_stroke_word.dart';
import 'package:hani_booki/screens/hani/hani_stroke/hani_stroke_widgets/hani_stroke_word.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BookiStrokeScreen extends StatefulWidget {
  final String keyCode;

  const BookiStrokeScreen({super.key, required this.keyCode});

  @override
  State<BookiStrokeScreen> createState() => _BookiStrokeScreenState();
}

class _BookiStrokeScreenState extends State<BookiStrokeScreen> {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    await _playSound(strokeData.bookiStrokeDataList[currentIndex].voicePath);
    setState(() {
      isPointerShown = false;
    });
    totalCompletedIndex++;

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
    verticalLottieDialog(
      onReset: () async {
        setState(() {
          isDialogShown = false;
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
      backgroundColor: Color(0xFFBDE45D),
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        isContent: true,
        title: ' ',
        isPortraitMode: true,
        onTapBackIcon: () => verticalBackDialog(true),
      ),
      body: isDialogShown
          ? Container()
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Color(0xFFE7610B), fontSize: 32, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '$totalCompletedIndex',
                            ),
                            TextSpan(
                                text: ' / ${strokeData.bookiStrokeDataList.length}', style: TextStyle(color: fontMain)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ClipRect(
                        child: SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: BookiStrokeWord(
                            strokeController: strokeData,
                            currentIndex: currentIndex,
                            resetNotifier: resetNotifier,
                            onComplete: _completeWord,
                            isPointerShown: isPointerShown,
                            strokeColor: bookiStrokeColors[strokeIndex],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    // child: Container(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Color(0xFFE7610B), borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Text(
                              strokeData.bookiStrokeDataList[currentIndex].phonetic,
                              style: TextStyle(
                                color: fontWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _onPrevWord();
                              },
                              child: currentIndex > 0
                                  ? Icon(
                                      Icons.skip_previous,
                                      size: 50,
                                      color: fontWhite,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _onResetTracing();
                              },
                              child: Icon(Icons.refresh, size: 50, color: fontWhite),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _onNextWord();
                              },
                              child: strokeData.bookiStrokeDataList.length - 1 > currentIndex
                                  ? Icon(Icons.skip_next, size: 50, color: fontWhite)
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
    }
    super.dispose();
  }
}
