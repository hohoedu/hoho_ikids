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
  int currectIndex = 0;

  @override
  void initState() {
    super.initState();
    answer = [
      quizData.haniQuizDataList[currectIndex].correct,
      quizData.haniQuizDataList[currectIndex].wrong,
    ]..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFDE5),
      appBar: MainAppBar(
        isContent: true,
        title: '공통으로 들어가는 한자를 찾아보세요!',
        titleStyle: TextStyle(
          fontSize: 22,
        ),
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.8 : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 12,
                child: Row(
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
                                    final imagePaths = [
                                      quizData.haniQuizDataList[currectIndex].first,
                                      quizData.haniQuizDataList[currectIndex].second,
                                      quizData.haniQuizDataList[currectIndex].third,
                                      quizData.haniQuizDataList[currectIndex].question,
                                    ];

                                    return Expanded(
                                      child: Image.network(
                                        imagePaths[index],
                                      ),
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
                          children: List.generate(
                            2,
                            (index) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      final isCorrect =
                                          answer[index] == quizData.haniQuizDataList[currectIndex].correct;
                                      Logger().d(isCorrect ? '정답' : '오답');
                                      if (isCorrect) {
                                        if (currectIndex == quizData.haniQuizDataList.length - 1) {
                                          return;
                                        } else {
                                          setState(() {
                                            currectIndex++;
                                            answer = [
                                              quizData.haniQuizDataList[currectIndex].correct,
                                              quizData.haniQuizDataList[currectIndex].wrong,
                                            ]..shuffle();
                                          });
                                        }
                                      }
                                    },
                                    child: Image.network(answer[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
