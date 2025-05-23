import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_make_card_data.dart';
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
  int currentIndex = 0;
  List<Map<String, String>> choices = [];

  @override
  void initState() {
    super.initState();
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

  void nextWord() {
    if (currentIndex < makeWord.makeCardDataList.length - 1) {
      setState(() {
        currentIndex++;
        shuffleChoices();
      });
    } else {
      Logger().d('게임 종료');
    }
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
                            child: DragTarget<String>(
                              onAccept: (data) {
                                if (data == 'correct') {
                                  nextWord();
                                } else {
                                  print("오답!");
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        color: Colors.white,
                                        child: Center(
                                            child: Text(
                                          '해와 달',
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
                                              Expanded(
                                                child: Image.network(
                                                  makeWord.makeCardDataList[currentIndex].first,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Expanded(
                                                  child: Image.network(
                                                makeWord.makeCardDataList[currentIndex].second,
                                                fit: BoxFit.contain,
                                              )),
                                            ],
                                          ),
                                          Align(
                                              alignment: Alignment.center,
                                              child: Image.asset('assets/images/icons/circle.png'))
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
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
                                      child: Image.network(choice['url']!, width: 100),
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
