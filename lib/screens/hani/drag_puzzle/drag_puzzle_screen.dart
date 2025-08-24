import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_drag_puzzle_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/loading_screen.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/contents_appbar.dart';
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

  bool _imagesPreloaded = false;

  late List<HaniDragPuzzleData> _puzzleSets;
  late AudioPlayer _audioPlayer;
  List<bool> isSolved = [];
  int currentIndex = 0;
  List<Map<String, dynamic>> shuffledCards = [];
  Size scaleSize = Size(0, 0);

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('match');
    _audioPlayer = AudioPlayer();
    _initPuzzleSets();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAllImages();
    });
  }

  Future<void> _preloadAllImages() async {
    final urls = <String>{};
    for (var set in _puzzleSets) {
      urls.add(set.boardImage);
      urls.addAll(set.questionImages);
      urls.addAll(set.cardImages);
    }
    await Future.wait(urls.map((url) => precacheImage(NetworkImage(url), context)));
    setState(() => _imagesPreloaded = true);
  }

  void _initPuzzleSets() {
    _puzzleSets = List.of(dragPuzzleData.dragPuzzleDataList)..shuffle();
    _prepareCurrentPuzzle();
  }

  void _prepareCurrentPuzzle() {
    final set = _puzzleSets[currentIndex];
    shuffledCards = List.generate(8, (i) => {'index': i, 'img': set.cardImages[i]})..shuffle();
    isSolved = List<bool>.filled(8, false);
  }

  void goToNextPuzzle() async {
    if (currentIndex < _puzzleSets.length - 1) {
      setState(() {
        currentIndex++;
        _prepareCurrentPuzzle();
      });
    } else {
      await starUpdateService('workbook', widget.keyCode);
      lottieDialog(
        onMain: () {
          Get.back();
          Get.back();
        },
        onReset: () {
          Get.back();
          resetPuzzle();
        },
      );
    }
  }

  Future<void> resetPuzzle() async {
    setState(() {
      _imagesPreloaded = false;
    });

    _puzzleSets = List.of(dragPuzzleData.dragPuzzleDataList)..shuffle();
    currentIndex = 0;

    await _preloadAllImages();

    setState(() {
      _prepareCurrentPuzzle();
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

  @override
  Widget build(BuildContext context) {
    if (!_imagesPreloaded) {
      return LoadingScreen();
    }

    final set = _puzzleSets[currentIndex];
    final boardImage = set.boardImage;
    final questionImages = set.questionImages;

    final double baseWidth = screenWidth >= 1000 ? 307.08 : 307.08;
    final double baseHeight = screenWidth >= 1000 ? 352.56 : 352.56;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF3FCFF),
      appBar: ContentsAppBar(
        isContent: true,
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 22),
            children: [
              TextSpan(text: '퍼즐을 맞춰 동화 장면을 완성해 보세요!  '),
              TextSpan(
                text: '( ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '${currentIndex + 1}',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' / ${dragPuzzleData.dragPuzzleDataList.length} )',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
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
                    // 왼쪽 Board 이미지 + DropTargets
                    Expanded(
                      flex: 55,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // 실제 영역의 크기를 constraints로 받아옴
                            final boardWidth = constraints.maxWidth;
                            final boardHeight =
                                screenWidth > 1000 ? boardWidth / (baseWidth / baseHeight) : constraints.maxHeight;

                            // 기준 크기 대비 스케일 계산
                            final scaleX = boardWidth / baseWidth;
                            final scaleY = boardHeight / baseHeight;

                            scaleSize = Size(scaleX, scaleY);
                            return Stack(
                              fit: StackFit.loose,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network(
                                    boardImage,
                                    width: boardWidth,
                                    height: boardHeight,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // 8개의 DropTarget을 배치
                                if (constraints.maxWidth > 0 && constraints.maxHeight > 0)
                                  ...List.generate(8, (index) {
                                    double top = 0;
                                    double left = 0;

                                    // if (index < 2) {
                                    //   top = 40;
                                    //   left = 70.0 + index * 90.0;
                                    // } else if (index < 5) {
                                    //   top = 140;
                                    //   left = 20.0 + (index - 2) * 95.0;
                                    // } else {
                                    //   top = 230;
                                    //   left = 20.0 + (index - 5) * 95.0;
                                    // }
                                    final bool tablet = screenWidth >= 1000;
                                    if (index == 0) {
                                      // index 0 위치
                                      top = tablet ? 62.5 : 40;
                                      left = tablet ? 72 : 70;
                                    } else if (index == 1) {
                                      // index 1 위치
                                      top = tablet ? 62 : 40;
                                      left = tablet ? 165 : 161;
                                    } else if (index == 2) {
                                      // index 2 위치
                                      top = tablet ? 144.6 : 140;
                                      left = tablet ? 25.3 : 20;
                                    } else if (index == 3) {
                                      // index 3 위치
                                      top = tablet ? 144.6 : 140;
                                      left = tablet ? 118.8 : 115;
                                    } else if (index == 4) {
                                      // index 4 위치
                                      top = tablet ? 141.5 : 138;
                                      left = tablet ? 210 : 205;
                                    } else if (index == 5) {
                                      // index 5 위치
                                      top = tablet ? 222 : 230;
                                      left = tablet ? 27 : 23;
                                    } else if (index == 6) {
                                      // index 6 위치
                                      top = tablet ? 223 : 230;
                                      left = tablet ? 120 : 115;
                                    } else if (index == 7) {
                                      // index 7 위치
                                      top = tablet ? 225 : 235;
                                      left = tablet ? 210 : 205;
                                    }

                                    return Positioned(
                                      top: top * scaleY,
                                      left: left * scaleX,
                                      child: AnimatedOpacity(
                                        opacity: isSolved[index] ? 0 : 1,
                                        duration: const Duration(milliseconds: 200),
                                        child: DragTarget<int>(
                                          onAccept: (data) async {
                                            if (data == index) {
                                              await _playSound(set.voices[index]);
                                              setState(() {
                                                isSolved[index] = true;
                                                if (isSolved.every((e) => e)) {
                                                  Future.delayed(
                                                    const Duration(milliseconds: 100),
                                                    () {
                                                      goToNextPuzzle();
                                                    },
                                                  );
                                                }
                                              });
                                            } else {
                                              setState(() {});
                                              SoundManager.playNo();
                                            }
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            return SizedBox(
                                              width: screenWidth >= 1000 ? 70 * scaleX : 80 * scaleX,
                                              height: screenWidth >= 1000 ? 70 * scaleY : 80 * scaleY,
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
                            );
                          },
                        ),
                      ),
                    ),

                    // 오른쪽 Draggable Grid
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

                              final RxSet<int> draggingIndices = <int>{}.obs;

                              return Obx(() {
                                final isDragging = draggingIndices.contains(realIndex);
                                final isSolvedNow = isSolved[realIndex];

                                if (isSolvedNow || isDragging) return SizedBox.shrink();

                                return Draggable<int>(
                                  data: realIndex,
                                  onDragStarted: () {
                                    draggingIndices.add(realIndex);
                                  },
                                  onDraggableCanceled: (_, __) {
                                    draggingIndices.remove(realIndex);
                                  },
                                  onDragEnd: (_) {
                                    draggingIndices.remove(realIndex);
                                  },
                                  feedback: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: screenWidth >= 1000 ? 70 * scaleSize.width : 80 * scaleSize.width,
                                      height: screenWidth >= 1000 ? 70 * scaleSize.height : 80 * scaleSize.height,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  childWhenDragging: const SizedBox.shrink(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: screenWidth >= 1000 ? 70 * scaleSize.width : 80 * scaleSize.width,
                                      height: screenWidth >= 1000 ? 70 * scaleSize.height : 80 * scaleSize.height,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              });
                            }),
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

  @override
  void dispose() {
    bgmController.stopBgm();
    _audioPlayer.dispose();
    imageCache.clear();
    imageCache.clearLiveImages();
    super.dispose();
  }
}
