import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_quiz_data.dart';
import 'package:hani_booki/services/hani/hani_quiz_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class QuizScreen extends StatefulWidget {
  final String keyCode;

  const QuizScreen({super.key, required this.keyCode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final userData = Get.find<UserDataController>().userData;
  late List<String> answer;
  final bgmController = Get.find<BgmController>();
  final quizData = Get.find<HaniQuizDataController>();
  late AudioPlayer _audioPlayer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('puzzle');
    _audioPlayer = AudioPlayer();
    _setupAnswer();
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e('Error playing sound: $e');
    }
  }

  void _setupAnswer() {
    answer = [
      quizData.haniQuizDataList[currentIndex].correct,
      quizData.haniQuizDataList[currentIndex].wrong,
    ]..shuffle();
  }

  Future<void> _onAnswerTap(int index) async {
    final isCorrect = answer[index] == quizData.haniQuizDataList[currentIndex].correct;
    if (!isCorrect) {
      await SoundManager.playNo();
      return;
    } else if (isCorrect) {
      await _playSound(quizData.haniQuizDataList[currentIndex].voice);
      await Future.delayed(
        Duration(seconds: 1),
        () {
          if (currentIndex >= quizData.haniQuizDataList.length - 1) {
            starUpdateService('quiz', widget.keyCode);
            lottieDialog(
              onMain: () {
                Get.back();
                Get.back();
              },
              onReset: () {
                Get.back();
                resetQuiz();
              },
            );
            return;
          }
          setState(() {
            currentIndex++;
            _setupAnswer();
          });
        },
      );
    }
  }

  Future<void> resetQuiz() async {
    await haniQuizService(userData!.id, widget.keyCode, userData!.year);
    setState(() {
      currentIndex = 0;
      _setupAnswer();
    });
    Logger().d('퀴즈가 리셋되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final quizItem = quizData.haniQuizDataList[currentIndex];
    final imagePaths = [
      quizItem.first,
      quizItem.second,
      quizItem.third,
      quizItem.question,
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFDE5),
      appBar: MainAppBar(
        isContent: true,
        title: '공통으로 들어가는 한자를 찾아보세요!',
        titleStyle: TextStyle(fontSize: 22),
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              Spacer(flex: 1),
              Expanded(
                flex: 12,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: _buildQuizContent(imagePaths, key: ValueKey(currentIndex)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(List<String> imagePaths, {required Key key}) {
    return Row(
      key: key,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (rowIndex) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: List.generate(2, (colIndex) {
                        final index = rowIndex * 2 + colIndex;
                        return Expanded(
                          child: Image.network(imagePaths[index]),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () => _onAnswerTap(index),
                      child: Image.network(answer[index], key: ValueKey('$currentIndex-$index')),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
