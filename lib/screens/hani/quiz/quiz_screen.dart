import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_quiz_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/hani/hani_quiz_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/loading_screen.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/contents_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class QuizScreen extends StatefulWidget {
  final String keyCode;

  const QuizScreen({super.key, required this.keyCode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final userData = Get.find<UserDataController>().userData;
  late List<String> answer;
  final bgmController = Get.find<BgmController>();
  final quizData = Get.find<HaniQuizDataController>();
  late AudioPlayer _audioPlayer;

  bool _imagesPreloaded = false;
  int currentIndex = 0;

  late AnimationController _moveController;
  late Animation<Offset> _moveAnimation;

  int _tappedIndex = -1;
  bool _answeredCorrect = false;
  bool _arrivedImage = false;

  final List<GlobalKey> _answerKeys = [GlobalKey(), GlobalKey()];

  final GlobalKey _targetKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('quiz');
    _audioPlayer = AudioPlayer();
    _setupAnswer();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAllImages();
    });
  }

  Future<void> _preloadAllImages() async {
    final urls = <String>{};
    for (var item in quizData.haniQuizDataList) {
      urls.addAll([
        item.first,
        item.second,
        item.third,
        item.question,
        item.correct,
        item.wrong,
      ]);
    }

    await Future.wait(urls.map((u) => precacheImage(NetworkImage(u), context)));

    setState(() => _imagesPreloaded = true);
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e('Error playing sound: $e');
    }
  }

  void _setupAnswer() {
    answer = [
      quizData.haniQuizDataList[currentIndex].correct,
      quizData.haniQuizDataList[currentIndex].wrong,
    ]..shuffle();
    _answeredCorrect = false;
    _tappedIndex = -1;
  }

  Future<void> _onAnswerTap(int index) async {
    if (_isAnimating) return;

    final isCorrect = answer[index] == quizData.haniQuizDataList[currentIndex].correct;

    if (!isCorrect) {
      await SoundManager.playNo();
      return;
    }

    _tappedIndex = index;
    await SoundManager.playCorrect();
    _playSound(quizData.haniQuizDataList[currentIndex].voice);

    setState(() {
      _answeredCorrect = true;
    });

    await animateMovingImage(fromKey: _answerKeys[index], toKey: _targetKey);

    setState(() {
      _arrivedImage = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      final lastIndex = quizData.haniQuizDataList.length - 1;

      if (currentIndex >= lastIndex) {
        starUpdateService('quiz', widget.keyCode);
        lottieDialog(
          onMain: () {
            Get.back();
            Get.back();
          },
          onReset: () {
            Get.back();
            resetQuiz();
          },
        );
      } else {
        setState(() {
          currentIndex++;
          _answeredCorrect = false;
          _arrivedImage = false;
          _tappedIndex = -1;
          _setupAnswer();
        });
      }
    });
  }

  // 정답 시 애니메이션
  Future<void> animateMovingImage({required GlobalKey fromKey, required GlobalKey toKey}) async {
    _isAnimating = true;

    final renderFrom = fromKey.currentContext!.findRenderObject() as RenderBox;
    final startOffset = renderFrom.localToGlobal(Offset.zero);
    final sizeFrom = renderFrom.size;

    final renderTo = toKey.currentContext!.findRenderObject() as RenderBox;
    final endOffset = renderTo.localToGlobal(Offset.zero);
    final sizeTo = renderTo.size;

    final overlay = Overlay.of(context)!;

    final animationListener = () {
      _overlayEntry!.markNeedsBuild();
    };

    _moveAnimation = Tween<Offset>(
      begin: Offset(startOffset.dx, startOffset.dy),
      end: Offset(
          endOffset.dx + (sizeTo.width - sizeFrom.width) / 2, endOffset.dy + (sizeTo.height - sizeFrom.height) / 2),
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOut))
      ..addListener(animationListener);

    _overlayEntry = OverlayEntry(builder: (_) {
      final current = _moveAnimation.value;
      return Positioned(
        left: current.dx,
        top: current.dy,
        width: sizeFrom.width,
        height: sizeFrom.height,
        child: Image.network(
          answer[_tappedIndex],
          fit: BoxFit.contain,
        ),
      );
    });

    overlay.insert(_overlayEntry!);

    await _moveController.forward();

    _overlayEntry?.remove();
    _moveController.reset();
    _moveAnimation.removeListener(animationListener);
    _overlayEntry = null;
    _isAnimating = false;
  }

  Future<void> resetQuiz() async {
    setState(() {
      _imagesPreloaded = false;
    });

    await haniQuizService(userData!.id, widget.keyCode, userData!.year);

    await _preloadAllImages();

    setState(() {
      currentIndex = 0;
      _answeredCorrect = false;
      _arrivedImage = false;
      _tappedIndex = -1;
      _setupAnswer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizItem = quizData.haniQuizDataList[currentIndex];
    final imagePaths = [
      quizItem.first,
      quizItem.second,
      quizItem.third,
      quizItem.question,
    ];

    Widget _buildLeftGridCell(int cellIndex) {
      if (cellIndex == 3 && _arrivedImage) {
        return Image.network(
          quizData.haniQuizDataList[currentIndex].correct,
          fit: BoxFit.contain,
        );
      } else {
        return Image.network(imagePaths[cellIndex], fit: BoxFit.contain);
      }
    }

    if (!_imagesPreloaded) {
      return LoadingScreen();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFDE5),
      appBar: ContentsAppBar(
        isContent: true,
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 22),
            children: [
              TextSpan(text: '세 개의 그림을 보고 공통되는 한자를 찾아보세요!  '),
              TextSpan(
                text: '( ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '${currentIndex + 1}',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' / ${quizData.haniQuizDataList.length} )',
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
            children: [
              Spacer(flex: 1),
              Expanded(
                flex: 12,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      key: ValueKey(currentIndex),
                      children: [
                        Expanded(
                          flex: screenWidth >= 1000 ? 3 : 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCD55),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(2, (rowIndex) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Row(
                                        children: List.generate(2, (colIndex) {
                                          final idx = rowIndex * 2 + colIndex;
                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: (idx == 3)
                                                  ? Container(key: _targetKey, child: _buildLeftGridCell(idx))
                                                  : _buildLeftGridCell(idx),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: List.generate(2, (idx) {
                              if (_answeredCorrect) {
                                return const Expanded(child: SizedBox.shrink());
                              }
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: GestureDetector(
                                    onTap: () => _onAnswerTap(idx),
                                    child: Image.network(
                                      answer[idx],
                                      key: _answerKeys[idx],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    _moveController.dispose();
    _audioPlayer.dispose();
    imageCache.clear();
    imageCache.clearLiveImages();
    super.dispose();
  }
}
