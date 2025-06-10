import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_make_word_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/hani/hani_make_word_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/loading_screen.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/contents_appbar.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

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

  bool _isPressed = false;
  bool _imagesPreloaded = false;
  bool _isInteractionDisabled = false;

  int currentIndex = 0;
  late String firstUrl = '';
  late String secondUrl = '';
  late bool firstIsPic;
  late bool secondIsPic;
  List<Map<String, String>> choices = [];

  double imageHeight = 0;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('word');
    loadCard();
    shuffleChoices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAllImages();
    });
  }

  Future<void> _preloadAllImages() async {
    final urls = <String>{
      for (var card in makeWord.makeWordDataList) ...[
        card.first,
        card.second,
        card.correct,
        card.wrong1,
        card.wrong2,
        card.wrong3,
        card.clear,
      ]
    }.toList();

    await Future.wait(urls.map((url) => precacheImage(NetworkImage(url), context)));

    setState(() => _imagesPreloaded = true);
  }

  void shuffleChoices() {
    final card = makeWord.makeWordDataList[currentIndex];
    choices = [
      {'url': card.correct, 'type': 'correct'},
      {'url': card.wrong1, 'type': 'wrong'},
      {'url': card.wrong2, 'type': 'wrong'},
      {'url': card.wrong3, 'type': 'wrong'},
    ]..shuffle();
    setState(() {});
  }

  void loadCard() {
    final card = makeWord.makeWordDataList[currentIndex];

    firstUrl = card.first;
    secondUrl = card.second;

    firstIsPic = !firstUrl.endsWith('word.png');
    secondIsPic = !secondUrl.endsWith('word.png');
  }

  void nextWord(String data) async {
    if (data == 'correct') {
      setState(() => _isInteractionDisabled = true);
      SoundManager.playCorrect();
      setState(() {
        if (firstIsPic) {
          firstUrl = makeWord.makeWordDataList[currentIndex].clear;
          firstIsPic = false;
        }
        if (secondIsPic) {
          secondUrl = makeWord.makeWordDataList[currentIndex].clear;
          secondIsPic = false;
        }
      });
      await Future.delayed(const Duration(milliseconds: 1000));

      _goNextCard();
      setState(() => _isInteractionDisabled = false);
    } else {
      await SoundManager.playNo();
    }
  }

  void _goNextCard() async {
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

      loadCard();
      shuffleChoices();
      _imagesPreloaded = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAllImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagesPreloaded) {
      return LoadingScreen();
    }

    return AbsorbPointer(
      absorbing: _isInteractionDisabled,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: ContentsAppBar(
          backgroundColor: Color(0xFFDFD7FE),
          isContent: true,
          title: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 22),
              children: [
                TextSpan(text: '설명에 알맞은 한자 카드를 찾아 단어를 완성하세요!  '),
                TextSpan(
                  text: '( ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${currentIndex + 1}',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' / ${makeWord.makeWordDataList.length} )',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          onTapBackIcon: () => showBackDialog(false),
        ),
        body: Center(
          child: SizedBox(
            width: screenWidth >= 1000
                ? MediaQuery.of(context).size.width * 0.9
                : MediaQuery.of(context).size.width * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: screenWidth >= 1000 ? 2 : 1),
                Expanded(
                  flex: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTapDown: (details) {
                                          setState(() {
                                            _isPressed = true;
                                          });
                                        },
                                        onTapUp: (details) {
                                          setState(() {
                                            _isPressed = false;
                                          });
                                        },
                                        onTapCancel: () {
                                          setState(() {
                                            _isPressed = false;
                                          });
                                        },
                                        onTap: () {
                                          Logger().d('사운드 재생!');
                                        },
                                        child: AnimatedScale(
                                          scale: _isPressed ? 0.9 : 1.0,
                                          duration: const Duration(milliseconds: 100),
                                          curve: Curves.easeOut,
                                          child: Image.asset('assets/images/icons/sound.png'),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Container(
                                            color: Color(0xFFFEFACD),
                                            child: Center(
                                              child: Text(
                                                makeWord.makeWordDataList[currentIndex].title,
                                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: firstIsPic
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFFDFD7FE),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '?',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 125,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily: 'BMJUA'),
                                                            ),
                                                          ),
                                                        )
                                                      : Image.network(
                                                          firstUrl,
                                                          fit: BoxFit.contain,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: secondIsPic
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFFDFD7FE),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '?',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 125,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily: 'BMJUA'),
                                                            ),
                                                          ),
                                                        )
                                                      : Image.network(
                                                          secondUrl,
                                                          fit: BoxFit.contain,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Image.asset(
                                      'assets/images/icons/plus.png',
                                      scale: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            children: choices.map((choice) {
                              return GestureDetector(
                                onTap: () => nextWord(choice['type']!),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.network(
                                        choice['url']!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
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
      ),
    );
  }

  @override
  void dispose() {
    imageCache.clear();
    imageCache.clearLiveImages();
    super.dispose();
  }
}
