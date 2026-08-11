import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_quiz_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/hani/hani_quiz_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/loading_screen.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/utils/star_event_mixin.dart';
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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin, StarEventMixin<QuizScreen> {
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

  // AnimatedSwitcher 전환 중 이전/다음 문제가 동시에 존재할 때 GlobalKey가 겹치면
  // Element가 강제 재부모화되어 정답 이미지가 다음 문제로 딸려 들어오는 버그가 생긴다.
  // 따라서 문제(_setupAnswer)마다 새 키를 발급한다.
  late List<GlobalKey> _answerKeys;

  late GlobalKey _targetKey;

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
    initStarEventFromServer(btype: 'H', hosu: widget.keyCode.substring(2, 4), gb: 'quiz');
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

    // 문제가 바뀔 때마다 새 GlobalKey를 발급해 AnimatedSwitcher 전환 중 키 충돌을 방지
    _answerKeys = [GlobalKey(), GlobalKey()];
    _targetKey = GlobalKey();
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

    if (!mounted) return;

    setState(() {
      _arrivedImage = true;
    });

    Future.delayed(Duration(seconds: 1), () async {
      if (!mounted) return;

      final lastIndex = quizData.haniQuizDataList.length - 1;

      if (currentIndex >= lastIndex) {
        starUpdateService('quiz', widget.keyCode);
        final result = await missionSaveService(missionNum: 2, gb: 'quiz', keycode: widget.keyCode);

        if (result.success) {
          await showStampDialog(widget.keyCode);
        }

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
    // 위젯이 이미 dispose되었으면 애니메이션 진행하지 않음
    if (!mounted) return;

    // RenderObject가 아직 준비되지 않았으면(레이아웃 전/위젯 소멸) 안전하게 종료
    final renderFrom = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final renderTo = toKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderFrom == null || renderTo == null) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _isAnimating = true;

    final startOffset = renderFrom.localToGlobal(Offset.zero);
    final sizeFrom = renderFrom.size;

    final endOffset = renderTo.localToGlobal(Offset.zero);
    final sizeTo = renderTo.size;

    // 애니메이션 도중 _tappedIndex가 -1로 초기화되어도 안전하도록 이미지 URL을 미리 캡처
    final movingImageUrl = (_tappedIndex >= 0 && _tappedIndex < answer.length) ? answer[_tappedIndex] : null;

    final animationListener = () {
      _overlayEntry?.markNeedsBuild();
    };

    _moveAnimation = Tween<Offset>(
      begin: Offset(startOffset.dx, startOffset.dy),
      end: Offset(endOffset.dx + (sizeTo.width - sizeFrom.width) / 2, endOffset.dy + (sizeTo.height - sizeFrom.height) / 2),
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.easeInOut))
      ..addListener(animationListener);

    _overlayEntry = OverlayEntry(builder: (_) {
      final current = _moveAnimation.value;
      return Positioned(
        left: current.dx,
        top: current.dy,
        width: sizeFrom.width,
        height: sizeFrom.height,
        child: movingImageUrl == null
            ? const SizedBox.shrink()
            : Image.network(
                movingImageUrl,
                fit: BoxFit.contain,
              ),
      );
    });

    overlay.insert(_overlayEntry!);

    await _moveController.forward();

    _overlayEntry?.remove();
    _overlayEntry = null;
    _moveAnimation.removeListener(animationListener);
    _isAnimating = false;

    // await 도중 위젯이 dispose되면 컨트롤러도 dispose되므로 reset 호출 금지
    if (mounted) {
      _moveController.reset();
    }
  }

  Future<void> resetQuiz() async {
    setState(() {
      _imagesPreloaded = false;
    });

    await haniQuizService(userData!.id, widget.keyCode, userData!.year);

    await _preloadAllImages();

    if (!mounted) return;

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
      body: Stack(
        children: [
          Center(
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
                                                  child: (idx == 3) ? Container(key: _targetKey, child: _buildLeftGridCell(idx)) : _buildLeftGridCell(idx),
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
          ...buildStarWidgets(widget.keyCode),
        ],
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
