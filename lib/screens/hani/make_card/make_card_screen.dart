import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_make_card_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/hani/hani_make_card_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class MakeCardScreen extends StatefulWidget {
  final String keyCode;

  const MakeCardScreen({super.key, required this.keyCode});

  @override
  State<MakeCardScreen> createState() => _MakeCardScreenState();
}

class _MakeCardScreenState extends State<MakeCardScreen> {
  final makeWord = Get.find<HaniMakeCardDataController>();
  final userData = Get.find<UserDataController>().userData;
  int currentIndex = 0;
  late String firstUrl = '';
  late String secondUrl = '';
  late bool firstIsPic;
  late bool secondIsPic;
  List<Map<String, String>> choices = [];

  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    loadCard();
    shuffleChoices();
  }

  void shuffleChoices() {
    final card = makeWord.makeCardDataList[currentIndex];
    choices = [
      {'url': card.correct, 'type': 'correct'},
      {'url': card.wrong, 'type': 'wrong'},
    ]..shuffle();
    setState(() {});
  }

  void loadCard() {
    final card = makeWord.makeCardDataList[currentIndex];

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
          firstUrl = makeWord.makeCardDataList[currentIndex].clear;
        }
        if (secondIsPic) {
          secondUrl = makeWord.makeCardDataList[currentIndex].clear;
        }
        isAnswered = true;
      });
    } else {
      await SoundManager.playNo();
    }
  }

  void _goNextCard() async {
    if (!isAnswered) return;
    if (currentIndex < makeWord.makeCardDataList.length - 1) {
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
    await haniMakeCardService(userData!.id, widget.keyCode, userData!.year);

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
      body: GestureDetector(
        onTap: () => _goNextCard(),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                Expanded(
                  flex: 12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 8,
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
                                        makeWord.makeCardDataList[currentIndex].title,
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
                                            firstIsPic
                                                ? Expanded(
                                                    child: DragTarget<String>(
                                                      onAccept: nextWord,
                                                      builder: (ctx, candidate, rejected) => AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 300),
                                                        transitionBuilder: (child, animation) =>
                                                            FadeTransition(opacity: animation, child: child),
                                                        child: Image.network(
                                                          firstUrl,
                                                          scale: 2,
                                                          key: ValueKey(firstUrl),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Expanded(
                                                    child: AnimatedSwitcher(
                                                      duration: const Duration(milliseconds: 300),
                                                      transitionBuilder: (child, animation) =>
                                                          FadeTransition(opacity: animation, child: child),
                                                      child: Image.network(
                                                        firstUrl,
                                                        key: ValueKey(firstUrl),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                            secondIsPic
                                                ? Expanded(
                                                    child: DragTarget<String>(
                                                      onAccept: nextWord,
                                                      builder: (ctx, candidate, rejected) => AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 300),
                                                        transitionBuilder: (child, animation) =>
                                                            FadeTransition(opacity: animation, child: child),
                                                        child: Image.network(
                                                          secondUrl,
                                                          scale: 2,
                                                          key: ValueKey(secondUrl),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Expanded(
                                                    child: AnimatedSwitcher(
                                                      duration: const Duration(milliseconds: 300),
                                                      transitionBuilder: (child, animation) =>
                                                          FadeTransition(opacity: animation, child: child),
                                                      child: Image.network(
                                                        secondUrl,
                                                        key: ValueKey(secondUrl),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            'assets/images/icons/plus.png',
                                            scale: 3,
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
                          child: !isAnswered
                              ? Column(
                                  children: choices.map((choice) {
                                    return Expanded(
                                      child: Padding(
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
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Icon(Icons.navigate_next),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
