import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

const _path = 'assets/images/booki/basket';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

// shortcut: 유관순(inmul-07) 한 문제만 하드코딩, 다른 인물이 생기면 서버 데이터로 교체
const _items = [
  ('object03-1.png', false), // 구운몽
  ('object07-1.png', true), // 무궁화
  ('object07-3.png', true), // 만세운동
  ('object07-2.png', true), // 일본 순사
  ('object25-1.png', false), // 플라이어호
  ('object10-1.png', false), // 다이너마이트
];

// 오브젝트를 놓을 자리 (left, top, width, height). 이미지는 자리 안에 비율 유지로 가운데 맞춤.
const _spots = [
  (70.0, 230.0, 275.0, 275.0),
  (428.0, 150.0, 322.0, 278.0),
  (295.0, 530.0, 395.0, 348.0),
  (1305.0, 290.0, 320.0, 312.0),
  (1600.0, 115.0, 315.0, 256.0),
  (1590.0, 560.0, 315.0, 298.0),
];

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final Set<int> _placed = {};
  final int _answerCount = _items.where((e) => e.$2).length;

  // _spotOf[아이템 인덱스] = 자리 인덱스
  List<int> _spotOf = List.generate(_items.length, (i) => i)..shuffle();

  void _reset() {
    _placed.clear();
    _spotOf = List.generate(_items.length, (i) => i)..shuffle();
  }

  void _onDrop(int index) {
    if (!_items[index].$2) {
      SoundManager.playNo(); // 오답은 받지 않으므로 아이템이 원래 자리로 돌아감
      return;
    }
    SoundManager.playCorrect();
    setState(() => _placed.add(index));

    if (_placed.length == _answerCount) {
      lottieDialog(
        onReset: () {
          Get.back();
          setState(_reset);
        },
        onMain: () {
          Get.back();
          Get.back();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        title: ' ',
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('$_path/basket_bg.png', fit: BoxFit.cover)),
          LayoutBuilder(builder: (context, c) {
            final s = min(c.maxWidth / _designW, c.maxHeight / _designH);
            return Center(
              child: SizedBox(
                width: _designW * s,
                height: _designH * s,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 40 * s,
                      child: Text(
                        '아래의 인물과 관련된 것을 바구니에 담아보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'BMJUA', fontSize: 46 * s, color: const Color(0xFF3A3A3A)),
                      ),
                    ),
                    Positioned(
                      left: 800 * s,
                      top: 140 * s,
                      width: 420 * s,
                      child: Image.asset('$_path/inmul-07.png'),
                    ),
                    _buildBasket(s),
                    for (int i = 0; i < _items.length; i++)
                      if (!_placed.contains(i)) _buildItem(i, s),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBasket(double s) {
    return Positioned(
      left: 705 * s,
      top: 590 * s,
      width: 595 * s,
      child: DragTarget<int>(
        onAcceptWithDetails: (d) => _onDrop(d.data),
        builder: (context, candidate, _) => AnimatedScale(
          scale: candidate.isEmpty ? 1 : 1.05,
          duration: const Duration(milliseconds: 150),
          child: Stack(
            children: [
              Image.asset('$_path/basket.png'),
              Positioned(
                left: 0,
                right: 0,
                top: 173 * s,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _answerCount; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * s),
                        child: Image.asset(
                          '$_path/${i < _placed.length ? 'cookie_check' : 'cookie_empty'}.png',
                          width: 90 * s,
                        ),
                      ), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i, double s) {
    final (left, top, width, height) = _spots[_spotOf[i]];
    final image = Image.asset('$_path/${_items[i].$1}', width: width * s, height: height * s);
    return Positioned(
      left: left * s,
      top: top * s,
      child: Draggable<int>(
        data: i,
        feedback: image,
        childWhenDragging: const SizedBox.shrink(),
        child: image,
      ),
    );
  }
}
