import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_relics_data.dart';
import 'package:hani_booki/screens/hani/relics/relics_widgets/spray_scratcher.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/source_image.dart';

class RelicsScreen extends StatefulWidget {
  /// [problems] 를 안 주면 haniRelicsService 가 받아 둔 목록을 씀
  const RelicsScreen({super.key, this.problems, this.random});

  final List<HaniRelicsData>? problems;
  final Random? random;

  @override
  State<RelicsScreen> createState() => _RelicsScreenState();
}

class _RelicsScreenState extends State<RelicsScreen> {
  static const _gap = 16.0;

  // relics_frame.png(1542x938) 안쪽 투명 영역 비율
  static const _frameAspect = 1542 / 938;
  static const _innerL = 105 / 1542, _innerR = 107 / 1542, _innerT = 103 / 938, _innerB = 105 / 938;

  late final Random _rand = widget.random ?? Random();
  late final List<HaniRelicsData> _all = widget.problems ?? Get.find<HaniRelicsDataController>().haniRelicsDataList;

  // 한 판 = 받은 문제(10개)를 섞어 7개를 차례로. 다시 하기면 새로 7개
  static const _problemsPerGame = 7;
  late List<HaniRelicsData> _game = _newGame();
  int _index = 0; // 이번 판 몇 번째 문제인지
  HaniRelicsData get _problem => _game[_index];
  // 정답·오답 보기 자리는 문제마다 섞음
  late List<({String img, bool correct})> _choices = _shuffleChoices();

  List<HaniRelicsData> _newGame() => (List.of(_all)..shuffle(_rand)).take(_problemsPerGame).toList();

  List<({String img, bool correct})> _shuffleChoices() =>
      [(img: _problem.answerImg, correct: true), (img: _problem.wrongImg, correct: false)]..shuffle(_rand);

  int _round = 0; // 문제가 바뀔 때 덮개를 새로 깔기 위한 키
  bool _cleared = false; // 다 긁어야 보기를 누를 수 있음
  bool _solved = false;
  int? _shaking; // 틀린 보기 흔들기
  int _shakeSeq = 0;

  void _onChoice(int i) {
    if (!_cleared || _solved) return;
    if (!_choices[i].correct) {
      SoundManager.playNo();
      setState(() {
        _shaking = i;
        _shakeSeq++;
      });
      return;
    }
    SoundManager.playCorrect();
    setState(() => _solved = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_index + 1 < _game.length) {
        setState(() => _showProblem(_index + 1)); // 다음 문제
        return;
      }
      lottieDialog(
        onReset: () {
          Get.back();
          setState(() {
            _game = _newGame();
            _showProblem(0);
          });
        },
        onMain: () {
          Get.back();
          Get.back();
        },
      );
    });
  }

  void _showProblem(int index) {
    _index = index;
    _round++;
    _choices = _shuffleChoices();
    _cleared = _solved = false;
    _shaking = null;
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);

    final side = max(16.0, max(safe.left, safe.right) * 0.8);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MainAppBar(
        isContent: false,
        title: '모래 속에 숨겨진 그림과 한자를 찾아보세요.',
        titleStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/hani/relics/relics_bg.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(side, kToolbarHeight - 8, side, 8),
            child: LayoutBuilder(
              builder: (context, c) {
                // 액자는 남은 높이를 꽉 채우되, 버튼 자리로 가로 22%는 남김 (아이패드처럼 덜 길쭉한 화면 대비)
                final frameW = min(c.maxHeight * _frameAspect, (c.maxWidth - _gap) * 0.78);
                return Row(
                  children: [
                    SizedBox(width: frameW, child: Center(child: _buildFrame())),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: _gap),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < _choices.length; i++) _buildButton(i),
                          ],
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
  }

  Widget _buildButton(int i) {
    Widget child = AnimatedScale(
      // 맞힌 보기는 살짝 커짐
      scale: _solved && _choices[i].correct ? 1.08 : 1,
      duration: const Duration(milliseconds: 200),
      child: sourceImage(_choices[i].img, fit: BoxFit.contain),
    );
    if (_shaking == i) {
      child = TweenAnimationBuilder<double>(
        key: ValueKey(_shakeSeq),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        builder: (context, t, child) => Transform.translate(offset: Offset(sin(t * pi * 6) * (1 - t) * 12, 0), child: child),
        child: child,
      );
    }
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AspectRatio(
          aspectRatio: 603 / 406,
          child: GestureDetector(
            key: ValueKey(_choices[i].img), // 보기 그림 주소로 찾음(자리는 섞이므로)
            onTap: () => _onChoice(i),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildFrame() {
    return AspectRatio(
      aspectRatio: _frameAspect,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: w * _innerL,
                right: w * _innerR,
                top: h * _innerT,
                bottom: h * _innerB,
                child: SprayScratcher(
                  key: ValueKey(_round),
                  onThreshold: () => setState(() => _cleared = true),
                  // 기기 크기와 상관없이 같은 손놀림으로 긁히도록 영역 폭의 13%
                  brushSize: w * (1 - _innerL - _innerR) * 0.13,
                  threshold: 75,
                  coverAsset: 'assets/images/hani/relics/relics_scratch_bg.png',
                  child: sourceImage(_problem.seekImg, fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: Image.asset('assets/images/hani/relics/relics_frame.png', fit: BoxFit.fill)),
              ),
            ],
          );
        },
      ),
    );
  }
}
