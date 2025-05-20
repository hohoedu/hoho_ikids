import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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
                                      'assets/images/temp/q1_1.png',
                                      'assets/images/temp/q1_2.png',
                                      'assets/images/temp/q1_3.png',
                                      'assets/images/temp/q00.png',
                                    ];

                                    return Expanded(
                                      child: Image.asset(
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
                              List<String> answer = ['a1', 'a2'];
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Image.asset('assets/images/temp/${answer[index]}.png'),
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
