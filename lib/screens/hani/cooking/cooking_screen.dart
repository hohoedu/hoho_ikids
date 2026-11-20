import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_cooking_data.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/source_image.dart';

/// 카드 하나: 서버 그림 주소(또는 테스트용 에셋)와 정답 여부
typedef CookingCard = ({String img, bool correct});

class CookingScreen extends StatefulWidget {
  /// [problems] 를 안 주면 haniCookingService 가 받아 둔 목록을 씀
  const CookingScreen({super.key, this.problems, this.random});

  final List<HaniCookingData>? problems;

  /// 테스트에서 문제·카드 자리를 고정할 때만 넘김
  final Random? random;

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  static const _dir = 'assets/images/hani/cooking';

  // 카드 자리 6곳: center는 무대(stage) 기준 비율 좌표, aspect는 그 자리 칸의 가로/세로. 카드는 판마다 자리를 섞음
  // 서버 그림 비율은 모르므로 그림은 칸 안에 맞춰 넣음(칸끼리는 안 겹치게 잡혀 있음)
  static const List<({Offset center, double aspect})> _spots = [
    (center: Offset(0.085, 0.40), aspect: 369 / 334),
    (center: Offset(0.258, 0.175), aspect: 382 / 341),
    (center: Offset(0.20, 0.80), aspect: 369 / 385),
    (center: Offset(0.735, 0.175), aspect: 369 / 352),
    (center: Offset(0.905, 0.42), aspect: 395 / 334),
    (center: Offset(0.82, 0.80), aspect: 435 / 410),
  ];

  static const _stageAspect = 2.2;
  static const _cardH = 0.33;

  final _found = <String>{};
  String? _shaking;
  int _shakeSeq = 0;
  bool _hovering = false;
  late final Random _rand = widget.random ?? Random();
  late final List<HaniCookingData> _all = widget.problems ?? Get.find<HaniCookingDataController>().haniCookingDataList;

  // 한 판 = 받은 문제(10개)를 섞어 7개를 차례로. 다시 하기면 새로 7개
  static const _problemsPerGame = 7;
  late List<HaniCookingData> _game = _newGame();
  int _index = 0; // 이번 판 몇 번째 문제인지
  HaniCookingData get _problem => _game[_index];
  late List<CookingCard> _cards = _cardsOf(_problem);
  late List<int> _spotOf = _shuffleSpots(); // 카드 i 가 놓일 자리 번호 (basket 과 같은 방식)

  List<HaniCookingData> _newGame() => (List.of(_all)..shuffle(_rand)).take(_problemsPerGame).toList();

  void _showProblem(int index) {
    _index = index;
    _found.clear();
    _shaking = null;
    _cards = _cardsOf(_problem);
    _spotOf = _shuffleSpots();
  }

  // 정답 4 + 오답 2. 자리가 6곳뿐이라 넘치면 자름
  List<CookingCard> _cardsOf(HaniCookingData p) => [
        for (final c in p.answers) (img: c.img, correct: true),
        for (final c in p.wrongs) (img: c.img, correct: false),
      ].take(_spots.length).toList();

  List<int> _shuffleSpots() => List.generate(_cards.length, (i) => i)..shuffle(_rand);

  int get _answerCount => _cards.where((c) => c.correct).length;

  void _onDrop(CookingCard card) {
    setState(() {
      _hovering = false;
      if (card.correct) {
        SoundManager.playCorrect();
        _found.add(card.img);
      } else {
        SoundManager.playNo();
        _shaking = card.img;
        _shakeSeq++;
      }
    });
    if (card.correct && _found.length == _answerCount) {
      // 마지막 체크 표시를 잠깐 보여 준 뒤
      Future.delayed(const Duration(milliseconds: 600), () {
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
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    // 가장자리 카드를 끌어야 하므로 노치 쪽 여백은 전부 비움
    final side = max(16.0, max(safe.left, safe.right));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MainAppBar(
        isContent: false,
        title: '아래의 주제와 관련된 것을 요리볼에 담아보세요.',
        titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('$_dir/cooking_bg.png', fit: BoxFit.cover)),
          Padding(
            padding: EdgeInsets.fromLTRB(side, kToolbarHeight - 8, side, 8),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = min(c.maxWidth, c.maxHeight * _stageAspect);
                return Center(
                  child: SizedBox(width: w, height: w / _stageAspect, child: _buildStage(w, w / _stageAspect)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(double w, double h) {
    Positioned at(double left, double top, double width, double height, Widget child) => Positioned(left: left, top: top, width: width, height: height, child: child);

    // 크기·위치 모두 무대 비율 → 기기가 달라도 같은 모양 (요리볼 아래 끝 = 무대 바닥)
    final signW = w * 0.3125, signH = signW * 327 / 529;
    final bowlW = w * 0.425, bowlH = bowlW * 428 / 829;
    final tigerH = h * 0.27, tigerW = tigerH * 284 / 347;
    final slot = h * 0.11;
    final signTop = h * 0.22, bowlTop = h * 0.99 - bowlH;
    const hover = Duration(milliseconds: 150);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        at((w - tigerW) / 2, h * 0.03, tigerW, tigerH, Image.asset('$_dir/cooking_tiger.png')),
        at(
          (w - signW) / 2,
          signTop,
          signW,
          signH,
          AnimatedScale(
            scale: _hovering ? 1.06 : 1,
            duration: hover,
            child: Stack(
              children: [
                Positioned.fill(child: Image.asset('$_dir/cooking_sign.png')),
                // 팻말 크림색 판(가로 9~90%, 세로 12~58%) 안, 살짝 위쪽 가운데. 주제가 길어지면 판 안에서 줄어듦
                Positioned(
                  left: signW * 0.12,
                  right: signW * 0.12,
                  top: signH * 0.10,
                  bottom: signH * 0.46,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _problem.topic,
                      style: TextStyle(
                        fontSize: signW * 0.17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE0452E),
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        at(
          (w - bowlW) / 2,
          bowlTop,
          bowlW,
          bowlH,
          AnimatedScale(scale: _hovering ? 1.06 : 1, duration: hover, child: Image.asset('$_dir/cooking_bowl.png')),
        ),
        // 정오답 표시: 요리볼 몸통 아래쪽(높이 70% 지점)
        at(
          (w - slot * (_answerCount * 1.25 - 0.25)) / 2,
          bowlTop + bowlH * 0.70 - slot / 2,
          slot * (_answerCount * 1.25 - 0.25),
          slot,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _answerCount; i++) Image.asset('$_dir/${i < _found.length ? 'cooking_check' : 'cooking_question'}.png', width: slot),
            ],
          ),
        ),
        // 요리볼과 팻말을 합친 넉넉한 영역에 떨어뜨리면 담김
        at(
          (w - bowlW) / 2,
          signTop,
          bowlW,
          bowlTop + bowlH - signTop,
          DragTarget<CookingCard>(
            onWillAcceptWithDetails: (_) {
              setState(() => _hovering = true);
              return true;
            },
            onLeave: (_) => setState(() => _hovering = false),
            onAcceptWithDetails: (d) => _onDrop(d.data),
            builder: (context, _, __) => const ColoredBox(color: Colors.transparent),
          ),
        ),
        for (final card in _cards)
          if (!_found.contains(card.img)) _buildCard(card, w, h),
      ],
    );
  }

  Widget _buildCard(CookingCard card, double w, double h) {
    // 카드는 놓인 자리의 칸 크기를 쓰고, 그림은 칸 안에 맞춰 넣음(요리볼·옆 카드와 안 겹치게)
    final spotOf = _spots[_spotOf[_cards.indexOf(card)]];
    final spot = spotOf.center;
    final ch = h * _cardH, cw = ch * spotOf.aspect;
    final image = sourceImage(card.img, width: cw, height: ch, fit: BoxFit.contain);

    Widget child = Draggable<CookingCard>(
      data: card,
      feedback: image,
      childWhenDragging: Opacity(opacity: 0.3, child: image),
      child: image,
    );

    // 틀린 카드는 제자리로 돌아와 좌우로 흔들림
    if (_shaking == card.img) {
      child = TweenAnimationBuilder<double>(
        key: ValueKey(_shakeSeq),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        builder: (context, t, child) => Transform.translate(offset: Offset(sin(t * pi * 6) * (1 - t) * 12, 0), child: child),
        child: child,
      );
    }

    return Positioned(
      key: ValueKey(card.img),
      left: spot.dx * w - cw / 2,
      top: spot.dy * h - ch / 2,
      width: cw,
      height: ch,
      child: child,
    );
  }
}
