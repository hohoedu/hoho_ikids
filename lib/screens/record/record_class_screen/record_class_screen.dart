import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/record/record_class_screen/record_class_widgets/record_high_five.dart';
import 'package:hani_booki/screens/record/record_class_screen/record_class_widgets/record_learning.dart';
import 'package:hani_booki/screens/record/record_class_screen/record_class_widgets/record_speech.dart';
import 'package:hani_booki/screens/record/record_class_screen/record_class_widgets/record_tencity.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';

class RecordClassScreen extends StatefulWidget {
  const RecordClassScreen({super.key});

  @override
  State<RecordClassScreen> createState() => _RecordClassScreenState();
}

class _RecordClassScreenState extends State<RecordClassScreen> {
  int selectedIndex = 0;
  final List<String> tabTitles = [
    '호호하니 학습 내용',
    'High-five 수업',
    '우리반 언어활동',
    '인성활동',
  ];
  final List<Widget> tabContents = [
    RecordLearning(),
    RecordHighFive(),
    RecordSpeech(),
    RecordTencity(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: MainAppBar(
        title: ' ',
        isContent: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            children: [
              Expanded(child: Container()),
              Expanded(
                flex: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              flex: 3,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 22, color: Color(0xFF3E2081)),
                                  children: [
                                    TextSpan(text: '호호하니유치원\n'),
                                    TextSpan(
                                        text: '이하율 어린이',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: '의\n'),
                                    TextSpan(
                                        text: '3호 호호하니\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: '언어활동 보고서',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: '가\n'),
                                    TextSpan(text: '도착했어요!\n\n'),
                                    TextSpan(
                                        text: '한달동안 5가지 핵심언어활동으로\n',
                                        style: TextStyle(
                                            fontSize: 10, color: fontSub)),
                                    TextSpan(
                                        text: '기초문해력을 길렀어요.',
                                        style: TextStyle(
                                            fontSize: 10, color: fontSub)),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Row(

                                  children: [
                                    Icon(Icons.navigate_before),
                                    Text('3호'),
                                    Icon(Icons.navigate_next),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        child: Column(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Container(
                                    child: Row(
                                      children: List.generate(
                                        4,
                                        (index) {
                                          bool isSelected =
                                              selectedIndex == index;
                                          return RecordClassTab(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                              });
                                            },
                                            fontColor: isSelected
                                                ? Color(0xFF3E2081)
                                                : Color(0xFFFFFFFF),
                                            color: selectedIndex == index
                                                ? Color(0xFFFFD200)
                                                : Color(0xFFA37EF2),
                                            text: tabTitles[index],
                                            child: Container(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )),
                            Expanded(
                              flex: 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: Offset(0, -3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: IndexedStack(
                                    index: selectedIndex,
                                    children: List.generate(
                                      tabTitles.length,
                                      (index) {
                                        return tabContents[index];
                                      },
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class RecordClassTab extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color fontColor;
  final Color color;
  final Widget child;

  const RecordClassTab({
    super.key,
    required this.onTap,
    required this.child,
    required this.color,
    required this.fontColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: color,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
