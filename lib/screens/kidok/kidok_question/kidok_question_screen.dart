import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/kidok/kidok_question_data.dart';
import 'package:hani_booki/screens/kidok/kidok_question/kidok_question_widgets/kidok_question_option.dart';
import 'package:hani_booki/screens/kidok/kidok_result/kidok_result_screen.dart';
import 'package:hani_booki/services/kidok/kidok_question_service.dart';
import 'package:hani_booki/services/kidok/kidok_result_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class KidokQuestionScreen extends StatefulWidget {
  final String bookCode;
  final String keycode;

  const KidokQuestionScreen({super.key, required this.bookCode, required this.keycode});

  @override
  State<KidokQuestionScreen> createState() => _KidokQuestionScreenState();
}

class _KidokQuestionScreenState extends State<KidokQuestionScreen> {
  final kidokQuestionController = Get.find<KidokQuestionDataController>();
  int currentNumber = 1;
  List<int?> selectedAnswers = List.filled(10, null);
  List<bool> matchedAnswers = List.filled(10, false);
  List<bool> correctAnswers = List.filled(10, false);
  List<bool> hideCheckMarks = List.filled(10, false);
  List<bool> showNextButtons = List.filled(10, false);
  int correctCount = 0;
  late AudioPlayer _audioPlayer;
  bool isCorrect = false;
  bool isComplete = false;
  bool showNextButton = false;

  Timer? answerTimer;

  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().pauseBgm();
    _audioPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kidokQuestion = kidokQuestionController.kidokQuestionData;
      if (kidokQuestion != null) {
        _playSound(kidokQuestion.sound);
      }
    });
  }

  Future<void> _fetchNextQuestion() async {
    setState(() {
      showNextButton = false;
      currentNumber++;
    });
    await kidokQuestionService(widget.bookCode, currentNumber);
  }

  Future<void> _fetchPrevQuestion() async {
    setState(() {
      currentNumber--;
      showNextButton = selectedAnswers[currentNumber - 1] != null;
    });
    await kidokQuestionService(widget.bookCode, currentNumber);
  }

  void matchingAnswer() {
    Future.delayed(Duration(seconds: 1));
    isCorrect = true;
    final answer = kidokQuestionController.kidokQuestionData!.answer;
    if (selectedAnswers[currentNumber - 1]! + 1 == int.parse(answer)) {
      setState(() {
        matchedAnswers[currentNumber - 1] = true;
        hideCheckMarks[currentNumber - 1] = true;
      });
    }
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final kidokQuestion = kidokQuestionController.kidokQuestionData;
    List<Map<String, dynamic>> options = [
      {'number': '1', 'text': kidokQuestion!.option1},
      {'number': '2', 'text': kidokQuestion.option2},
      {'number': '3', 'text': kidokQuestion.option3},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kidokColor,
      appBar: MainAppBar(
        isContent: true,
        isKidok: true,
        title: '',
        onTapBackIcon: () => showKidokBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Stack(
                            children: [
                              Positioned(
                                child: CustomPaint(
                                  size: Size(
                                    double.infinity,
                                    double.infinity,
                                  ),
                                  painter: KidokShadowPainter(),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: EdgeInsets.all(8.0),
                                child: ClipPath(
                                  clipper: KidokQuestionClipper(),
                                  child: Container(
                                    decoration: BoxDecoration(color: mBackWhite, boxShadow: [BoxShadow()]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Center(
                                                child: Text('${kidokQuestion.questionNumber}',
                                                    style: const TextStyle(
                                                      // 색 바꿀지 물어보자
                                                      color: Colors.green,
                                                      fontSize: 40,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    softWrap: false),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 8.0, right: 16.0),
                                              child: Text(
                                                autoWrapText(kidokQuestion.question, 22),
                                                style: TextStyle(
                                                    color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                _playSound(kidokQuestion.sound);
                              },
                              child: Image.asset(
                                'assets/images/kidoc.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: kidokQuestion.isExample,
                  child: Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.yellow, border: Border.all(color: Colors.orange)),
                        child: Center(
                          child: RichText(
                            text: exampleText(kidokQuestion.example),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () async {
                                  if (currentNumber != 1) await _fetchPrevQuestion();
                                  setState(() {});
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (kidokQuestionController.kidokQuestionData != null) {
                                      _playSound(kidokQuestionController.kidokQuestionData!.sound);
                                    }
                                  });
                                },
                                child: currentNumber != 1
                                    ? Icon(Icons.navigate_before, size: 30.sp, color: fontMain)
                                    : SizedBox.shrink(),
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(options.length, (index) {
                                  final option = options[index];

                                  return GestureDetector(
                                    onTap: () {
                                      if (selectedAnswers[currentNumber - 1] != null) return;

                                      setState(() {
                                        selectedAnswers[currentNumber - 1] = index;
                                      });


                                      answerTimer?.cancel();
                                      answerTimer = Timer(const Duration(seconds: 1), () {
                                        if (mounted) {
                                          setState(() {
                                            if (selectedAnswers[currentNumber - 1]! + 1 == int.parse(kidokQuestion.answer)) {
                                              correctAnswers[currentNumber - 1] = true;
                                              hideCheckMarks[currentNumber - 1] = true;

                                              SoundManager.playCorrect();
                                            } else {
                                              hideCheckMarks[currentNumber - 1] = false;
                                              SoundManager.playNo();
                                            }
                                            showNextButtons[currentNumber -1 ] = true;
                                          });
                                        }
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        KidokQuestionOption(
                                          number: option['number'],
                                          text: option['text'],
                                          constraints: constraints,
                                        ),

                                        if (selectedAnswers[currentNumber - 1] == index && !hideCheckMarks[currentNumber - 1])
                                          Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Image.asset(
                                              'assets/images/icons/check.png',
                                              scale: 3,
                                            ),
                                          ),
                                        if (int.parse(kidokQuestion.answer) == index + 1 && showNextButtons[currentNumber - 1])
                                          Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Image.asset('assets/images/icons/circle.png'),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isCorrect = (selectedAnswers[currentNumber - 1] != null);
                                  });
                                  matchingAnswer();
                                  if (currentNumber != 10) {
                                    await _fetchNextQuestion();

                                    setState(() {
                                      isCorrect = (selectedAnswers[currentNumber - 1] != null);
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (kidokQuestionController.kidokQuestionData != null) {
                                        _playSound(kidokQuestionController.kidokQuestionData!.sound);
                                      }
                                    });
                                  } else if (currentNumber == 10) {
                                    showGameCompleteDialog(
                                      title: '정답 확인',
                                      content: '모든 문제를 다 풀었어요!',
                                      confirm: () {
                                        Get.back();
                                        Get.back();
                                        kidokResultService(selectedAnswers, widget.bookCode, widget.keycode);
                                        Get.to(() => KidokResultScreen(
                                              matchedAnswers: matchedAnswers,
                                            ));
                                      },
                                      confirmText: '정답 확인',
                                      cancel: () {
                                        if (Get.isDialogOpen ?? false) {
                                          Get.back; // 다이얼로그만 닫기
                                        }
                                      },
                                      cancelText: '문제 확인',
                                    );
                                  }
                                },
                                child: (selectedAnswers[currentNumber - 1] != null && showNextButtons[currentNumber-1])
                                    ? Icon(Icons.navigate_next, size: 30.sp, color: fontMain)
                                    : SizedBox.shrink(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    Get.find<BgmController>().resumeBgm();
    super.dispose();
  }
}

class KidokQuestionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path()
      ..moveTo(0, 0.2 * h)
      ..quadraticBezierTo(0, 0, 0.05 * w, 0)
      ..lineTo(0.85 * w, 0)
      ..quadraticBezierTo(0.95 * w, 0, 0.95 * w, 0.2 * h)
      ..lineTo(0.95 * w, 0.5 * h)
      ..quadraticBezierTo(0.95 * w, 0.7 * h, w, 0.8 * h)
      ..lineTo(w, 0.8 * h)
      ..quadraticBezierTo(w, 0.9 * h, 0.95 * w, 0.875 * h)
      ..lineTo(0.95 * w, 0.9 * h)
      ..quadraticBezierTo(0.95 * w, h, 0.9 * w, h)
      ..lineTo(0.05 * w, h)
      ..quadraticBezierTo(0, h, 0, 0.85 * h)
      ..lineTo(0, 0.1 * h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class KidokShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double offset = 0.0; // 그림자 오프셋 크기
    Path shadowPath = KidokQuestionClipper().getClip(size).shift(Offset(offset, offset));

    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1) // 그림자 색상
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10); // 블러 효과

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
