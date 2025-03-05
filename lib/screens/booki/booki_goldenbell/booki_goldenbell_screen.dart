import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/booki/booki_goldenbell_data.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BookiGoldenbellScreen extends StatefulWidget {
  final String keyCode;

  const BookiGoldenbellScreen({super.key, required this.keyCode});

  @override
  State<BookiGoldenbellScreen> createState() => _BookiGoldenbellScreenState();
}

class _BookiGoldenbellScreenState extends State<BookiGoldenbellScreen> {
  final bookiGoldenbellDataController =
      Get.find<BookiGoldenbellDataController>();

  int currentIndex = 0;
  int? selectedAnswerIndex;
  bool? isCorrect;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookiGoldenbell =
          bookiGoldenbellDataController.bookiGoldenbellDataList[0];
      if (bookiGoldenbell.voicePath.isNotEmpty) {
        _playSound(bookiGoldenbell.voicePath);
      }
    });
  }

  Future<void> _playSound(List<String> url) async {
    try {
      await _audioPlayer.setUrl(url[currentIndex]);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("Error playing sound: $e");
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        resetQuestionState();
      });
    }
  }

  void nextQuestion() {
    if (currentIndex <
        bookiGoldenbellDataController
                .bookiGoldenbellDataList[0].questions.length -
            1) {
      setState(() {
        currentIndex++;
        resetQuestionState();
      });
    }
  }

  void endQuestion() async {
    await starUpdateService('bell', widget.keyCode);
    lottieDialog(
      onMain: () {
        Get.back();
        Get.back();
      },
      onReset: () {
        Get.back();
        setState(() {
          currentIndex = 0;
          resetQuestionState();
        });
      },
    );
  }

  void checkAnswer(int answerIndex) {
    if (isCorrect == true) return;
    int correctAnswer = int.parse(
        bookiGoldenbellDataController.bookiGoldenbellDataList[0]
            .correctAnswer[currentIndex]);

    setState(() {
      selectedAnswerIndex = answerIndex;
      isCorrect = (answerIndex + 1) == correctAnswer;
    });

    if (isCorrect == true) {
      SoundManager.playCorrect();

    } else {
      SoundManager.playNo();
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          selectedAnswerIndex = null;
          isCorrect = null;
        });
      });
    }
  }
  void resetQuestionState() {
    selectedAnswerIndex = null;
    isCorrect = null;
  }

  @override
  Widget build(BuildContext context) {
    final questions =
        bookiGoldenbellDataController.bookiGoldenbellDataList[0].questions;
    final answers = [
      bookiGoldenbellDataController
          .bookiGoldenbellDataList[0].answer_1[currentIndex],
      bookiGoldenbellDataController
          .bookiGoldenbellDataList[0].answer_2[currentIndex],
      bookiGoldenbellDataController
          .bookiGoldenbellDataList[0].answer_3[currentIndex],
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: mBackWhite,
      appBar: MainAppBar(
        title: ' ',
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isIOS
              ? MediaQuery.of(context).size.width * 0.85
              : double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(questions[currentIndex]),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      if (currentIndex > 0)
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: prevQuestion,
                            child: Icon(
                              Icons.navigate_before,
                              size: 30.sp,
                              color: Colors.black26,
                            ),
                          ),
                        )
                      else
                        const Spacer(flex: 1),
                      ...answers.asMap().entries.map((entry) {
                        int index = entry.key;
                        String answer = entry.value;

                        return Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: selectedAnswerIndex == null
                                      ? () => checkAnswer(index)
                                      : null,
                                  child: Image.network(answer),
                                ),
                                if (selectedAnswerIndex != null &&
                                    selectedAnswerIndex == index)
                                  Icon(
                                    isCorrect == true ? Icons.circle_outlined : Icons.close,
                                    color: isCorrect == true ? Colors.green : Colors.red,
                                    size: 40.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      // next 버튼: 정답을 맞췄을 때만 보이도록 처리 (마지막 문제인 경우 endQuestion 호출)
                      if (isCorrect == true)
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (currentIndex < questions.length - 1) {
                                nextQuestion();
                              } else {
                                endQuestion();
                              }
                            },
                            child: Icon(
                              Icons.navigate_next,
                              size: 30.sp,
                              color: Colors.black26,
                            ),
                          ),
                        )
                      else
                        const Spacer(flex: 1),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
