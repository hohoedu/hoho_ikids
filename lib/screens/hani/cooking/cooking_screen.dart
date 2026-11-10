import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';

typedef CookingCard = ({String asset, double aspect, bool correct, Offset center});

class CookingScreen extends StatefulWidget {
  const CookingScreen({super.key});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  static const _dir = 'assets/images/hani/cooking';

  // shortcut: 샘플 문제 하드코딩, 서버 데이터 붙일 때 교체
  static const _topic = '자연';

  // center는 무대(stage) 기준 비율 좌표, aspect는 이미지 가로/세로
  static const List<CookingCard> _cards = [
    (asset: '$_dir/cooking_card_iceberg.png', aspect: 369 / 334, correct: true, center: Offset(0.085, 0.40)),
    (asset: '$_dir/cooking_card_weightlifting.png', aspect: 382 / 341, correct: false, center: Offset(0.258, 0.175)),
    (asset: '$_dir/cooking_card_mountain.png', aspect: 369 / 385, correct: true, center: Offset(0.20, 0.80)),
    (asset: '$_dir/cooking_card_stream.png', aspect: 369 / 352, correct: true, center: Offset(0.735, 0.175)),
    (asset: '$_dir/cooking_card_orchard.png', aspect: 395 / 334, correct: true, center: Offset(0.905, 0.42)),
    (asset: '$_dir/cooking_card_pediatrics.png', aspect: 435 / 410, correct: false, center: Offset(0.82, 0.80)),
  ];

  static const _stageAspect = 2.2;
  static const _cardH = 0.33;

  final _found = <String>{};
  String? _shaking;
  int _shakeSeq = 0;
  bool _hovering = false;

  int get _answerCount => _cards.where((c) => c.correct).length;

  void _onDrop(CookingCard card) {
    setState(() {
      _hovering = false;
      if (card.correct) {
        _found.add(card.asset);
      } else {
        _shaking = card.asset;
        _shakeSeq++;
      }
    });
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
                      _topic,
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
          if (!_found.contains(card.asset)) _buildCard(card, w, h),
      ],
    );
  }

  Widget _buildCard(CookingCard card, double w, double h) {
    final ch = h * _cardH, cw = ch * card.aspect;
    final image = Image.asset(card.asset, width: cw, height: ch);

    Widget child = Draggable<CookingCard>(
      data: card,
      feedback: image,
      childWhenDragging: Opacity(opacity: 0.3, child: image),
      child: image,
    );

    // 틀린 카드는 제자리로 돌아와 좌우로 흔들림
    if (_shaking == card.asset) {
      child = TweenAnimationBuilder<double>(
        key: ValueKey(_shakeSeq),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        builder: (context, t, child) => Transform.translate(offset: Offset(sin(t * pi * 6) * (1 - t) * 12, 0), child: child),
        child: child,
      );
    }

    return Positioned(
      key: ValueKey(card.asset),
      left: card.center.dx * w - cw / 2,
      top: card.center.dy * h - ch / 2,
      width: cw,
      height: ch,
      child: child,
    );
  }
}
