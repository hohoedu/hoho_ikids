import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_make_word_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/hani/hani_make_word_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class MakeWordScreen extends StatefulWidget {
  final String keyCode;

  const MakeWordScreen({super.key, required this.keyCode});

  @override
  State<MakeWordScreen> createState() => _MakeWordScreenState();
}

class _MakeWordScreenState extends State<MakeWordScreen> {
  final bgmController = Get.find<BgmController>();
  final makeWord = Get.find<HaniMakeWordDataController>();
  final userData = Get.find<UserDataController>().userData;

  final GlobalKey _imageKey = GlobalKey();

  int currentIndex = 0;
  late String firstUrl = '';
  late String secondUrl = '';
  late bool firstIsPic;
  late bool secondIsPic;
  List<Map<String, String>> choices = [];

  bool isAnswered = false;

  double imageHeight = 0;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('word');
    loadCard();
    shuffleChoices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void shuffleChoices() {
    final card = makeWord.makeWordDataList[currentIndex];
    choices = [
      {'url': card.correct, 'type': 'correct'},
      {'url': card.wrong, 'type': 'wrong'},
    ]..shuffle();
    setState(() {});
  }

  void loadCard() {
    final card = makeWord.makeWordDataList[currentIndex];

    firstUrl = card.first;
    secondUrl = card.second;

    firstIsPic = !firstUrl.endsWith('word.png');
    secondIsPic = !secondUrl.endsWith('word.png');

    isAnswered = false;
  }

  void nextWord(String data) async {
    if (data == 'correct') {
      await SoundManager.playCorrect();
      setState(() {
        if (firstIsPic) {
          firstUrl = makeWord.makeWordDataList[currentIndex].clear;
        }
        if (secondIsPic) {
          secondUrl = makeWord.makeWordDataList[currentIndex].clear;
        }
        isAnswered = true;
      });
    } else {
      await SoundManager.playNo();
    }
  }

  void _goNextCard() async {
    if (!isAnswered) return;
    if (currentIndex < makeWord.makeWordDataList.length - 1) {
      setState(() {
        currentIndex++;
        loadCard();
        shuffleChoices();
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
          resetCard();
        },
      );
    }
  }

  Future<void> resetCard() async {
    await haniMakeWordService(userData!.id, widget.keyCode, userData!.year);
    setState(() {
      currentIndex = 0;
      firstUrl = '';
      secondUrl = '';
      firstIsPic = false;
      secondIsPic = false;
      isAnswered = false;

      loadCard();
      shuffleChoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFDFD7FE),
      appBar: MainAppBar(
        isContent: true,
        title: '알맞은 한자카드를 그림에 넣어 단어를 완성하세요!',
        titleStyle: TextStyle(
          fontSize: 22,
        ),
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width:
              screenWidth >= 1000 ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: screenWidth >= 1000 ? 2 : 1),
              Expanded(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    color: Colors.white,
                                    child: Center(
                                        child: Text(
                                      makeWord.makeWordDataList[currentIndex].title,
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          // First Image
                                          Expanded(
                                            child: firstIsPic
                                                ? DragTarget<String>(
                                                    onAccept: nextWord,
                                                    builder: (ctx, candidate, rejected) => AnimatedSwitcher(
                                                      duration: const Duration(milliseconds: 300),
                                                      transitionBuilder: (child, animation) =>
                                                          FadeTransition(opacity: animation, child: child),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          imageHeight = constraints.maxHeight;
                                                          return Image.network(
                                                            firstUrl,
                                                            scale: 2,
                                                            key: ValueKey(firstUrl),
                                                            fit: BoxFit.contain,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    transitionBuilder: (child, animation) =>
                                                        FadeTransition(opacity: animation, child: child),
                                                    child: LayoutBuilder(
                                                      builder: (context, constraints) {
                                                        imageHeight = constraints.maxHeight;
                                                        return Image.network(
                                                          firstUrl,
                                                          key: ValueKey(firstUrl),
                                                          fit: BoxFit.contain,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                          ),
                                          // Second Image
                                          Expanded(
                                            child: secondIsPic
                                                ? DragTarget<String>(
                                                    onAccept: nextWord,
                                                    builder: (ctx, candidate, rejected) => AnimatedSwitcher(
                                                      duration: const Duration(milliseconds: 300),
                                                      transitionBuilder: (child, animation) =>
                                                          FadeTransition(opacity: animation, child: child),
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          return Image.network(
                                                            secondUrl,
                                                            scale: 2,
                                                            key: ValueKey(secondUrl),
                                                            fit: BoxFit.contain,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    transitionBuilder: (child, animation) =>
                                                        FadeTransition(opacity: animation, child: child),
                                                    child: LayoutBuilder(
                                                      builder: (context, constraints) {
                                                        return Image.network(
                                                          secondUrl,
                                                          key: ValueKey(secondUrl),
                                                          fit: BoxFit.contain,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: (imageHeight) / 3,
                                        left: 0,
                                        right: 0,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            'assets/images/icons/plus.png',
                                            scale: 3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: isAnswered
                            ? GestureDetector(
                                onTap: () {
                                  _goNextCard();
                                },
                                child: Image.asset(
                                  'assets/images/icons/next.png',
                                  scale: 0.5,
                                  color: Color(0xFFFFFFFF),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: choices.map((choice) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Draggable<String>(
                                        data: choice['type']!,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: Image.network(
                                              choice['url']!,
                                              width: MediaQuery.of(context).size.width * 0.15,
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: Image.network(choice['url']!),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Image.network(choice['url']!),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
