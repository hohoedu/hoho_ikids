import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/booki/booki_match_data.dart';
import 'package:hani_booki/screens/booki/booki_home/booki_home_screen.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class MatchScreen extends StatefulWidget {
  final String keyCode;

  const MatchScreen({super.key, required this.keyCode});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  final bookiMatchDataController =
      Get.find<BookiMatchDataController>();
final bgmController = Get.find<BgmController>();
  late List<String> images;
  late Map<int, int> pairs;
  int? firstSelectedIndex;
  Set<int> matchedCards = {};
  late List<GlobalKey<FlipCardState>> cardKeys;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('match');
    _initializeGameData();
  }

  void _initializeGameData() {
    final backImages =
        bookiMatchDataController.bookiMatchDataList[0].backImagePairs;

    final random = Random();
    final selectedIndices = <int>{};

    while (selectedIndices.length < 4) {
      selectedIndices.add(random.nextInt(8));
    }

    final selectedPairs =
        selectedIndices.map((index) => backImages[index]).toList();

    images = [];
    pairs = {};
    int index = 0;

    for (var pair in selectedPairs) {
      final firstImage = pair["first"];
      final secondImage = pair["second"];
      if (firstImage != null && secondImage != null) {
        images.add(firstImage);
        images.add(secondImage);
        pairs[index] = index + 1;
        pairs[index + 1] = index;
        index += 2;
      }
    }

    final shuffledIndices = List.generate(images.length, (i) => i)..shuffle();

    final shuffledImages = List<String>.from(images);
    final newPairs = <int, int>{};
    for (int i = 0; i < shuffledIndices.length; i++) {
      shuffledImages[i] = images[shuffledIndices[i]];
      newPairs[i] = shuffledIndices.indexOf(pairs[shuffledIndices[i]]!);
    }

    images = shuffledImages;
    pairs = newPairs;

    cardKeys =
        List.generate(images.length, (index) => GlobalKey<FlipCardState>());
  }

  void _resetGame() {
    setState(() {
      firstSelectedIndex = null;
      matchedCards.clear();
      isAnimating = false;
      _initializeGameData();
    });
  }

  void _handleTap(int index) async {
    // 애니메이션 진행 중이거나 이미 맞춘 카드, 또는 같은 카드 탭 시 무시
    if (isAnimating ||
        matchedCards.contains(index) ||
        firstSelectedIndex == index) return;

    // 첫 번째 카드 선택
    if (firstSelectedIndex == null) {
      setState(() {
        firstSelectedIndex = index;
        isAnimating = true; // 애니메이션 중으로 설정
      });
      cardKeys[index].currentState?.toggleCard();

      // 첫 번째 카드 애니메이션 시간(예: 300ms) 동안 입력 차단
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          isAnimating = false;
        });
      });
    } else {
      // 두 번째 카드 선택 시
      setState(() {
        isAnimating = true;
      });
      cardKeys[index].currentState?.toggleCard();

      // 두 카드가 일치하는 경우
      if (pairs[firstSelectedIndex!] == index) {
        SoundManager.playCorrect();
        setState(() {
          matchedCards.add(firstSelectedIndex!);
          matchedCards.add(index);
        });
        // 애니메이션 완료 후 상태 리셋
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            firstSelectedIndex = null;
            isAnimating = false;
          });
        });
      } else {
        // 두 카드가 일치하지 않는 경우
        SoundManager.playNo();
        Future.delayed(const Duration(milliseconds: 1000), () {
          cardKeys[firstSelectedIndex!].currentState?.toggleCard();
          cardKeys[index].currentState?.toggleCard();
          setState(() {
            firstSelectedIndex = null;
            isAnimating = false;
          });
        });
      }
    }

    // 모든 카드가 맞춰졌다면
    if (matchedCards.length == images.length) {
      await starUpdateService('img', widget.keyCode);
      lottieDialog(
        onReset: () {
          _resetGame();
          Get.back();
        },
        onMain: () {
          Get.back();
          Get.back();
          Get.off(() => BookiHomeScreen(keyCode: widget.keyCode));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final frontImages =
        bookiMatchDataController.bookiMatchDataList[0].frontImages;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFF00909F),
      appBar: MainAppBar(
        title: ' ',
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Center(
              // AbsorbPointer로 전체 입력을 제어합니다.
              child: AbsorbPointer(
                absorbing: isAnimating, // isAnimating이 true이면 터치 입력을 무시
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: images.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: FlipCard(
                        key: cardKeys[index],
                        flipOnTouch: false,
                        front: Image.network(
                          frontImages[index],
                          fit: BoxFit.contain,
                        ),
                        back: Center(
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
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
