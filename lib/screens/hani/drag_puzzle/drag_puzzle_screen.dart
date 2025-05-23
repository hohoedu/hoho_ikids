import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_drag_puzzle_data.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';

class DragPuzzleScreen extends StatefulWidget {
  final String keyCode;

  const DragPuzzleScreen({super.key, required this.keyCode});

  @override
  State<DragPuzzleScreen> createState() => _DragPuzzleScreenState();
}

class _DragPuzzleScreenState extends State<DragPuzzleScreen> {
  final dragPuzzleData = Get.find<HaniDragPuzzleDataController>();
  List<bool> isSolved = List.generate(8, (_) => false);
  int currentIndex = 0;
  List<Map<String, dynamic>> shuffledCards = [];

  @override
  void initState() {
    super.initState();
    shuffleCards(currentIndex);
  }

  void shuffleCards(int index) {
    final cardImages = dragPuzzleData.dragPuzzleDataList[index].cardImages;

    shuffledCards = List.generate(
      8,
          (i) => {
        'index': i,      // 정답 위치 (DragTarget index와 비교용)
        'img': cardImages[i],
      },
    )..shuffle(); // 드래그 카드만 셔플
  }

  void goToNextPuzzle() {
    if (currentIndex < dragPuzzleData.dragPuzzleDataList.length - 1) {
      setState(() {
        currentIndex++;
        isSolved = List.generate(8, (_) => false);
        shuffleCards(currentIndex);
      });
    } else {

    }
  }

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
                                      dragPuzzleData.dragPuzzleDataList[currentIndex].boardImage,
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
                                                setState(() {
                                                  isSolved[index] = true;

                                                  if (isSolved.every((e) => e)) {
                                                    // 모든 퍼즐 조각이 맞춰졌을 때
                                                    Future.delayed(const Duration(milliseconds: 300), () {
                                                      goToNextPuzzle(); // 다음 퍼즐로 이동
                                                    });
                                                  }
                                                });
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
                                                  dragPuzzleData.dragPuzzleDataList[currentIndex].questionImages[index],
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
                                    final item = shuffledCards[index];
                                    final realIndex = item['index']; // 정답 위치
                                    final imageUrl = item['img'];

                                    if (isSolved[realIndex]) return const SizedBox.shrink();

                                    return Draggable<int>(
                                      data: realIndex,
                                      feedback: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
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
