import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';

class DragPuzzleScreen extends StatefulWidget {
  const DragPuzzleScreen({super.key});

  @override
  State<DragPuzzleScreen> createState() => _DragPuzzleScreenState();
}

class _DragPuzzleScreenState extends State<DragPuzzleScreen> {
  List<bool> isSolved = List.generate(8, (_) => false);

  final String mainImageUrl = 'https://picsum.photos/id/1005/400/300';

  final List<String> questionImages = List.generate(8, (index) => 'https://picsum.photos/id/${20 + index}/60/60');
  final List<String> answerImages = List.generate(8, (index) => 'https://picsum.photos/id/${20 + index}/60/60');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF3FcFF),
      appBar: MainAppBar(
        isContent: true,
        title: '퍼즐을 맞춰 동화 장면을 완성해 보세요',
        titleStyle: TextStyle(
          fontSize: 22,
        ),
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 1),
              Expanded(
                flex: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Expanded(
                            flex: 55,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.network(
                                      mainImageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  ...List.generate(
                                    8,
                                    (index) {
                                      late double left, top;

                                      if (index < 2) {
                                        // 위 2개
                                        top = 20;
                                        left = 80.0 + index * 100.0;
                                      } else if (index < 5) {
                                        // 중간 3개
                                        top = 110;
                                        left = 40.0 + (index - 2) * 100.0;
                                      } else {
                                        // 아래 3개
                                        top = 200;
                                        left = 40.0 + (index - 5) * 100.0;
                                      }

                                      return Positioned(
                                        top: top,
                                        left: left,
                                        child: AnimatedOpacity(
                                          opacity: isSolved[index] ? 0 : 1,
                                          duration: const Duration(milliseconds: 400),
                                          child: DragTarget<int>(
                                            onAccept: (data) {
                                              if (data == index) {
                                                setState(() => isSolved[index] = true);
                                              }
                                            },
                                            builder: (context, candidateData, rejectedData) => Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.white),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  questionImages[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 45,
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFBEEBFA),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: GridView.count(
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: List.generate(8, (index) {
                                    if (isSolved[index]) return const SizedBox.shrink();

                                    return Draggable<int>(
                                      data: index,
                                      feedback: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          answerImages[index],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            answerImages[index],
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          answerImages[index],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ]),
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
