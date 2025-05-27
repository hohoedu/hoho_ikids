import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_drag_puzzle_data.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class DragPuzzleScreen extends StatefulWidget {
  final String keyCode;

  const DragPuzzleScreen({super.key, required this.keyCode});

  @override
  State<DragPuzzleScreen> createState() => _DragPuzzleScreenState();
}

class _DragPuzzleScreenState extends State<DragPuzzleScreen> {
  final dragPuzzleData = Get.find<HaniDragPuzzleDataController>();
  final bgmController = Get.find<BgmController>();
  final GlobalKey _imageKey = GlobalKey();

  late List<HaniDragPuzzleData> _puzzleSets;
  late AudioPlayer _audioPlayer;
  List<bool> isSolved = [];
  int currentIndex = 0;
  List<Map<String, dynamic>> shuffledCards = [];
  Size? boardSize;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('puzzle');
    _audioPlayer = AudioPlayer();
    _initPuzzleSets();
    _prepareCurrentPuzzle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _imageKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox;
        final newSize = renderBox.size;
        if (mounted) {
          setState(() {
            boardSize = newSize;
          });
        }
      }
    });
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e('Error playing sound: $e');
    }
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
    await starUpdateService('puz', widget.keyCode);
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
                                fit: StackFit.loose,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.network(
                                      boardImage,
                                      key: _imageKey,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (boardSize != null)
                                    ...List.generate(8, (index) {
                                      const double baseWidth = 307.08;
                                      const double baseHeight = 352.56;

                                      final scaleX = boardSize!.width / baseWidth;
                                      final scaleY = boardSize!.height / baseHeight;

                                      final double puzzleWidth = 85 * scaleX;
                                      final double puzzleHeight = 85 * scaleY;

                                      double left, top;
                                      if (index < 2) {
                                        top = 20;
                                        left = 71.0 + index * 100.0;
                                      } else if (index < 5) {
                                        top = 130;
                                        left = 20.0 + (index - 2) * 100.0;
                                      } else {
                                        top = 240;
                                        left = 20.0 + (index - 5) * 100.0;
                                      }

                                      return Positioned(
                                        top: top * scaleY,
                                        left: left * scaleX,
                                        child: AnimatedOpacity(
                                          opacity: isSolved[index] ? 0 : 1,
                                          duration: const Duration(milliseconds: 400),
                                          child: DragTarget<int>(
                                            onAccept: (data) async {
                                              if (data == index) {
                                                await _playSound(set.voices[index]);
                                                setState(() {
                                                  isSolved[index] = true;
                                                  if (isSolved.every((e) => e)) {
                                                    Future.delayed(const Duration(milliseconds: 300), () {
                                                      goToNextPuzzle();
                                                    });
                                                  }
                                                });
                                              } else {
                                                SoundManager.playNo();
                                              }
                                            },
                                            builder: (context, candidateData, rejectedData) {
                                              return SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    questionImages[index],
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }),
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
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 80,
                                            height: 80,
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
