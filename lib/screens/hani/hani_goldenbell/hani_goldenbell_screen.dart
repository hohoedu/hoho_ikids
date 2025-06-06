import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/hani/hani_goldenbell_data.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class HaniGoldenbellScreen extends StatefulWidget {
  final String keyCode;

  const HaniGoldenbellScreen({super.key, required this.keyCode});

  @override
  State<HaniGoldenbellScreen> createState() => _HaniGoldenbellScreenState();
}

class _HaniGoldenbellScreenState extends State<HaniGoldenbellScreen> {
  final haniGoldenbellDataController = Get.find<HaniGoldenbellDataController>();

  int currentIndex = 0;
  int? selectedAnswerIndex;
  bool? isCorrect;
  late AudioPlayer _audioPlayer;

  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final haniGoldenbell = haniGoldenbellDataController.haniGoldenbellDataList[0];
      if (haniGoldenbell.voicePath.isNotEmpty) {
        _playSound(haniGoldenbell.voicePath);
      }
    });
  }

  Future<void> _playSound(List<String> url) async {
    try {
      await _audioPlayer.setUrl(url[currentIndex]);
      _audioPlayer.play();
    } catch (e) {}
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        resetQuestionState();
        _playSound(haniGoldenbellDataController.haniGoldenbellDataList[0].voicePath);
      });
    }
  }

  void nextQuestion() {
    if (currentIndex < haniGoldenbellDataController.haniGoldenbellDataList[0].questions.length - 1) {
      setState(() {
        currentIndex++;
        resetQuestionState();
        _playSound(haniGoldenbellDataController.haniGoldenbellDataList[0].voicePath);
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
    _resetTimer?.cancel();

    int correctAnswer = int.parse(haniGoldenbellDataController.haniGoldenbellDataList[0].correctAnswer[currentIndex]);

    bool tappedAnswerIsCorrect = (answerIndex + 1) == correctAnswer;

    setState(() {
      selectedAnswerIndex = answerIndex;
      isCorrect = tappedAnswerIsCorrect;
    });

    if (tappedAnswerIsCorrect == true) {
      SoundManager.playCorrect();
    } else {
      SoundManager.playNo();
      _resetTimer = Timer(Duration(milliseconds: 500), () {
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
    final questions = haniGoldenbellDataController.haniGoldenbellDataList[0].questions;
    final answers = [
      haniGoldenbellDataController.haniGoldenbellDataList[0].answer_1[currentIndex],
      haniGoldenbellDataController.haniGoldenbellDataList[0].answer_2[currentIndex],
      haniGoldenbellDataController.haniGoldenbellDataList[0].answer_3[currentIndex],
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
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
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
                                  onTap: () => checkAnswer(index),
                                  child: Image.network(answer),
                                ),
                                if (selectedAnswerIndex != null && selectedAnswerIndex == index)
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
    _audioPlayer.stop();
    _resetTimer?.cancel();
    super.dispose();
  }
}
