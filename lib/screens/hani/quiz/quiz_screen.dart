import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_quiz_data.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class QuizScreen extends StatefulWidget {
  final String keyCode;

  const QuizScreen({super.key, required this.keyCode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<String> answer;
  final quizData = Get.find<HaniQuizDataController>();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnswer();
  }

  void _setupAnswer() {
    answer = [
      quizData.haniQuizDataList[currentIndex].correct,
      quizData.haniQuizDataList[currentIndex].wrong,
    ]..shuffle();
  }

  Future<void> _onAnswerTap(int index) async {
    final isCorrect = answer[index] == quizData.haniQuizDataList[currentIndex].correct;
    Logger().d(isCorrect ? '정답' : '오답');

    if (!isCorrect) return;

    if (currentIndex == quizData.haniQuizDataList.length - 1) {
      // 마지막 문제일 경우 처리
      return;
    }

    await Future.delayed(Duration(milliseconds: 300)); // 자연스럽게 전환
    setState(() {
      currentIndex++;
      _setupAnswer();
    });
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
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.8 : double.infinity,
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
      key: key, // 문제 전환 감지용 key
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
