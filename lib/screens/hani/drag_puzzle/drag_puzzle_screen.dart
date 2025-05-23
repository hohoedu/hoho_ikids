import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_drag_puzzle_data.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class DragPuzzleScreen extends StatefulWidget {
  final String keyCode;

  const DragPuzzleScreen({super.key, required this.keyCode});

  @override
  State<DragPuzzleScreen> createState() => _DragPuzzleScreenState();
}

class _DragPuzzleScreenState extends State<DragPuzzleScreen> {
  final dragPuzzleData = Get.find<HaniDragPuzzleDataController>();

  late List<HaniDragPuzzleData> _puzzleSets;

  List<bool> isSolved = [];
  int currentIndex = 0;
  List<Map<String, dynamic>> shuffledCards = [];

  @override
  void initState() {
    super.initState();

    _initPuzzleSets();

    _prepareCurrentPuzzle();
  }

  void _initPuzzleSets() {
    _puzzleSets = List.of(dragPuzzleData.dragPuzzleDataList)..shuffle();
  }

  void _prepareCurrentPuzzle() {
    final set = _puzzleSets[currentIndex];
    shuffledCards = List.generate(8, (i) => {'index': i, 'img': set.cardImages[i]})..shuffle();

    isSolved = List<bool>.filled(8, false);
  }

  void completeGame() async {
    // await starUpdateService('card', widget.keyCode);
    Future.delayed(
      Duration(seconds: 1),
      () {
        lottieDialog(
          onReset: () {
            _resetGame();
            Get.back();
          },
          onMain: () {
            Get.back();
            Get.back();
          },
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _initPuzzleSets();
      currentIndex = 0;
      _prepareCurrentPuzzle();
    });
  }

  void goToNextPuzzle() {
    if (currentIndex < _puzzleSets.length - 1) {
      setState(() {
        currentIndex++;
        _prepareCurrentPuzzle();
      });
    } else {
      completeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final set = _puzzleSets[currentIndex];
    final boardImage = set.boardImage;
    final questionImages = set.questionImages;

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
                                      boardImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  ...List.generate(
                                    8,
                                    (index) {
                                      late double left, top;
                                      if (index < 2) {
                                        top = 20;
                                        left = 80.0 + index * 100.0;
                                      } else if (index < 5) {
                                        top = 110;
                                        left = 40.0 + (index - 2) * 100.0;
                                      } else {
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
                                                    Future.delayed(const Duration(milliseconds: 300), () {
                                                      goToNextPuzzle();
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
                                    final item = shuffledCards[index];
                                    final realIndex = item['index'];
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
