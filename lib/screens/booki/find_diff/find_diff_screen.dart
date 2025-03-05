import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/booki/booki_find_diff_data.dart';
import 'package:hani_booki/screens/booki/booki_home/booki_home_screen.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_screen.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class FindDiffScreen extends StatefulWidget {
  final String keyCode;

  const FindDiffScreen({super.key, required this.keyCode});

  @override
  State<FindDiffScreen> createState() => _FindDiffScreenState();
}

class _FindDiffScreenState extends State<FindDiffScreen> {
  final bgmController = Get.find<BgmController>();
  final bookiFindDiffController = Get.find<BookiFindDiffDataController>();

  final Set<int> foundCorrectIndexes = {};

  Offset? temporaryCorrectOffset;
  Offset? temporaryWrongOffset;
  int currentIndex = 0;

  static const double actualImageWidth = 739;
  static const double actualImageHeight = 900;

  @override
  void initState() {
    SoundManager.playFind();
    bgmController.playBgm('find_diff');
    super.initState();
  }

  List<Rect> computeCorrectRegions(
      double containerWidth, double containerHeight,
      {required bool isLeft}) {
    double scale = min(
        containerWidth / actualImageWidth, containerHeight / actualImageHeight);

    double leftAdjustment = isLeft ? 20.0 : 0.0;

    double offX = isLeft
        ? (containerWidth - (actualImageWidth * scale)) - leftAdjustment
        : 0;
    double offY = (containerHeight - (actualImageHeight * scale)) / 2;
    final rawCorrectRegions =
        bookiFindDiffController.bookiFindDiffDataList[currentIndex].findAdress;
    return rawCorrectRegions.map((region) {
      final double x1 = (region[0] as num).toDouble();
      final double y1 = (region[1] as num).toDouble();
      final double x2 = (region[2] as num).toDouble();
      final double y2 = (region[3] as num).toDouble();

      double left = offX + min(x1, x2) * scale;
      double top = offY + min(y1, y2) * scale;
      double right = offX + max(x1, x2) * scale;
      double bottom = offY + max(y1, y2) * scale;
      return Rect.fromLTRB(left, top, right, bottom);
    }).toList();
  }

  int? getCorrectIndex(Offset touchOffset, List<Rect> regions) {
    for (int i = 0; i < regions.length; i++) {
      if (regions[i].contains(touchOffset)) return i;
    }
    return null;
  }

  void handleTouch(
    Offset touchOffset, {
    required bool isLeft,
    required List<Rect> regions,
    required double containerWidth,
    required double containerHeight,
  }) {
    final correctIndex = getCorrectIndex(touchOffset, regions);

    if (correctIndex != null && !foundCorrectIndexes.contains(correctIndex)) {
      SoundManager.playCorrect();
      setState(() {
        foundCorrectIndexes.add(correctIndex);
        temporaryCorrectOffset = touchOffset;
      });
      // 모든 정답을 찾은 경우
      if (foundCorrectIndexes.length == regions.length) {
        if (currentIndex ==
            bookiFindDiffController.bookiFindDiffDataList.length - 1) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await starUpdateService('find', widget.keyCode);
            lottieDialog(
              onReset: () {
                Get.back();
                resetQuestion();
              },
              onMain: () {
                Get.back();
                Get.back();
                Get.off(() => BookiHomeScreen(keyCode: widget.keyCode));
              },
            );
          });
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            nextQuestion();
          });
        }
      }
    } else if (correctIndex == null) {
      SoundManager.playNo();
      setState(() {
        temporaryWrongOffset = touchOffset;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          temporaryWrongOffset = null;
        });
      });
    }
  }

  void resetQuestion() {
    setState(() {
      currentIndex = 0;
      foundCorrectIndexes.clear();
      temporaryCorrectOffset = null;
      temporaryWrongOffset = null;
    });
  }

  void nextQuestion() {
    if (currentIndex <
        bookiFindDiffController.bookiFindDiffDataList.length - 1) {
      setState(() {
        currentIndex++;
        foundCorrectIndexes.clear();
      });
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        foundCorrectIndexes.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          width: Platform.isIOS
              ? MediaQuery.of(context).size.width * 0.85
              : double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double containerWidth = constraints.maxWidth / 2 - 16;
              final double containerHeight = constraints.maxHeight - 16;

              final leftRegions = computeCorrectRegions(
                  containerWidth, containerHeight,
                  isLeft: true);
              final rightRegions = computeCorrectRegions(
                  containerWidth, containerHeight,
                  isLeft: false);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 9,
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          double iconSize = 25.sp;
                          return Row(
                            children: [
                              // 왼쪽 이미지 영역
                              Expanded(
                                flex: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTapUp: (details) {
                                      handleTouch(
                                        details.localPosition,
                                        isLeft: true,
                                        regions: leftRegions,
                                        containerWidth: containerWidth,
                                        containerHeight: containerHeight,
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Image.network(
                                            bookiFindDiffController
                                                .bookiFindDiffDataList[
                                                    currentIndex]
                                                .image_1,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        // 디버그용: 정답 영역 표시
                                        // ...leftRegions
                                        //     .asMap()
                                        //     .entries
                                        //     .map((entry) {
                                        //   final idx = entry.key;
                                        //   final rect = entry.value;
                                        //   return Positioned(
                                        //     left: rect.left,
                                        //     top: rect.top,
                                        //     child: Container(
                                        //       width: rect.width,
                                        //       height: rect.height,
                                        //       decoration: BoxDecoration(
                                        //         border: Border.all(
                                        //             color: Colors.red, width: 1),
                                        //       ),
                                        //       child: Center(
                                        //         child: Text(
                                        //           '$idx',
                                        //           style: TextStyle(
                                        //               color: Colors.red,
                                        //               fontSize: 10.sp),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   );
                                        // }).toList(),
                                        // 정답 영역
                                        ...foundCorrectIndexes.map((index) {
                                          double rawLeft =
                                              leftRegions[index].center.dx -
                                                  iconSize / 2;
                                          double rawTop =
                                              leftRegions[index].center.dy -
                                                  iconSize / 2;
                                          double leftPos = rawLeft.clamp(
                                              0.0, containerWidth - iconSize);
                                          double topPos = rawTop.clamp(
                                              0.0, containerHeight - iconSize);
                                          return Positioned(
                                            left: leftPos,
                                            top: topPos,
                                            child: SizedBox(
                                              width: iconSize,
                                              child: Image.asset(
                                                  'assets/images/icons/correct.png',
                                                  fit: BoxFit.contain),
                                            ),
                                          );
                                        }).toList(),
                                        // 오답 터치 시 빨간 X 아이콘
                                        if (temporaryWrongOffset != null)
                                          Positioned(
                                            left: (temporaryWrongOffset!.dx -
                                                    iconSize / 2)
                                                .clamp(0.0,
                                                    containerWidth - iconSize),
                                            top: (temporaryWrongOffset!.dy -
                                                    iconSize / 2)
                                                .clamp(0.0,
                                                    containerHeight - iconSize),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: iconSize,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(flex: 1),
                              // 오른쪽 이미지 영역 (Align: centerLeft)
                              Expanded(
                                flex: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTapUp: (details) {
                                      handleTouch(
                                        details.localPosition,
                                        isLeft: false,
                                        regions: rightRegions,
                                        containerWidth: containerWidth,
                                        containerHeight: containerHeight,
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Image.network(
                                            bookiFindDiffController
                                                .bookiFindDiffDataList[
                                                    currentIndex]
                                                .image_2,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        // 디버그용: 정답 영역 표시
                                        // ...rightRegions
                                        //     .asMap()
                                        //     .entries
                                        //     .map((entry) {
                                        //   final idx = entry.key;
                                        //   final rect = entry.value;
                                        //   return Positioned(
                                        //     left: rect.left,
                                        //     top: rect.top,
                                        //     child: Container(
                                        //       width: rect.width,
                                        //       height: rect.height,
                                        //       decoration: BoxDecoration(
                                        //         border: Border.all(
                                        //             color: Colors.red, width: 1),
                                        //       ),
                                        //       child: Center(
                                        //         child: Text(
                                        //           '$idx',
                                        //           style: TextStyle(
                                        //               color: Colors.red,
                                        //               fontSize: 10.sp),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   );
                                        // }).toList(),
                                        // 정답 영역
                                        ...foundCorrectIndexes.map((index) {
                                          double rawLeft =
                                              rightRegions[index].center.dx -
                                                  iconSize / 2;
                                          double rawTop =
                                              rightRegions[index].center.dy -
                                                  iconSize / 2;
                                          double leftPos = rawLeft.clamp(
                                              0.0, containerWidth - iconSize);
                                          double topPos = rawTop.clamp(
                                              0.0, containerHeight - iconSize);
                                          return Positioned(
                                            left: leftPos,
                                            top: topPos,
                                            child: SizedBox(
                                              width: iconSize,
                                              child: Image.asset(
                                                  'assets/images/icons/correct.png',
                                                  fit: BoxFit.contain),
                                            ),
                                          );
                                        }).toList(),
                                        // 오답 터치 시 빨간 X 아이콘
                                        if (temporaryWrongOffset != null)
                                          Positioned(
                                            left: (temporaryWrongOffset!.dx -
                                                    iconSize / 2)
                                                .clamp(0.0,
                                                    containerWidth - iconSize),
                                            top: (temporaryWrongOffset!.dy -
                                                    iconSize / 2)
                                                .clamp(0.0,
                                                    containerHeight - iconSize),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: iconSize,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
