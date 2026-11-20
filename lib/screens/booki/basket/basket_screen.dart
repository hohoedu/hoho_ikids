import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_basket_data.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/source_image.dart';

const _path = 'assets/images/booki/basket';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

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
  /// [problems] 를 안 주면 bookiBasketService 가 받아 둔 목록을 씀
  const BasketScreen({super.key, this.problems, this.random});

  final List<BookiBasketData>? problems;

  /// 테스트에서 문제·자리를 고정할 때만 넘김
  final Random? random;

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  late final Random _rand = widget.random ?? Random();
  late final List<BookiBasketData> _all = widget.problems ?? Get.find<BookiBasketDataController>().bookiBasketDataList;

  // 한 판 = 받은 문제(10개)를 섞어 7개를 차례로. 다시 하기면 새로 7개
  static const _problemsPerGame = 7;
  late List<BookiBasketData> _game = _newGame();
  int _index = 0; // 이번 판 몇 번째 문제인지
  BookiBasketData get _problem => _game[_index];
  late List<({String img, bool correct})> _items = _itemsOf(_problem);
  final Set<int> _placed = {};
  int get _answerCount => _items.where((e) => e.correct).length;

  // _spotOf[아이템 인덱스] = 자리 인덱스
  late List<int> _spotOf = _shuffleSpots();

  List<BookiBasketData> _newGame() => (List.of(_all)..shuffle(_rand)).take(_problemsPerGame).toList();

  // 정답 3 + 오답 3. 자리가 6곳뿐이라 넘치면 자름
  List<({String img, bool correct})> _itemsOf(BookiBasketData p) => [
        for (final img in p.answerImgs) (img: img, correct: true),
        for (final img in p.wrongImgs) (img: img, correct: false),
      ].take(_spots.length).toList();

  List<int> _shuffleSpots() => List.generate(_items.length, (i) => i)..shuffle(_rand);

  void _showProblem(int index) {
    _index = index;
    _placed.clear();
    _items = _itemsOf(_problem);
    _spotOf = _shuffleSpots();
  }

  void _onDrop(int index) {
    if (!_items[index].correct) {
      SoundManager.playNo(); // 오답은 받지 않으므로 아이템이 원래 자리로 돌아감
      return;
    }
    SoundManager.playCorrect();
    setState(() => _placed.add(index));

    if (_placed.length < _answerCount) return;
    // 마지막 체크 표시를 잠깐 보여 준 뒤 다음 문제, 7문제를 다 풀면 결과
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_index + 1 < _game.length) {
        setState(() => _showProblem(_index + 1));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        title: '아래의 인물과 관련된 것을 바구니에 담아보세요.',
        titleStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
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
                    // 인물 칸(예전 인물 그림 603x746 크기). 서버 그림 비율이 달라도 칸 안에 맞춤
                    Positioned(
                      left: 800 * s,
                      top: 140 * s,
                      width: 420 * s,
                      height: 520 * s,
                      child: sourceImage(_problem.personImg, fit: BoxFit.contain),
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
    final image = sourceImage(_items[i].img, width: width * s, height: height * s, fit: BoxFit.contain);
    return Positioned(
      key: ValueKey(_items[i].img),
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
