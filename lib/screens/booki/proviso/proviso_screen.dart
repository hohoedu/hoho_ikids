import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

const _path = 'assets/images/booki/proviso';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

const _bg = Color(0xFFF6F9E5);
const _brown = Color(0xFF5B3A24);
const _clueFill = Color(0xFFFFF8EC);
const _clueBorder = Color(0xFFE9D8BD);
const _text = Color(0xFF3A3A3A);

// shortcut: 샘플 두 문제만 하드코딩, 실제 문제가 생기면 서버 데이터로 교체
// (제목, 이미지 단서 여부, 단서들, 인물 보기들, 정답 인덱스)
const _questions = [
  (
    '단서를 보고 관련된 인물을 맞혀보세요.',
    true,
    ['clude-20-1.png', 'clude-20-2.png'],
    ['inmul14.png', 'inmul20.png'],
    1, // 마틴 루터 킹
  ),
  (
    '단서를 보고 어떤 인물인지 맞혀보세요.',
    false,
    [
      '나무에서 떨어지는 사과를 보고 궁금해했어요.',
      '모든 물체가 서로 끌어당긴다는 것을 알아냈어요.',
      '햇빛이 여러 가지 색으로 나뉜다는 것을 밝혔어요.',
    ],
    ['inmul14.png', 'inmul-16.png'],
    1, // 뉴턴
  ),
];

class ProvisoScreen extends StatefulWidget {
  const ProvisoScreen({super.key});

  @override
  State<ProvisoScreen> createState() => _ProvisoScreenState();
}

class _ProvisoScreenState extends State<ProvisoScreen> {
  int _q = 0;
  int? _picked; // 정답을 고른 뒤 다음 문제로 넘어가기 전까지 입력 잠금
  late List<int> _order; // 인물 보기 배치 순서 (값 = 보기 인덱스)

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _q = 0;
    _setQuestion();
  }

  void _setQuestion() {
    _picked = null;
    _order = List.generate(_questions[_q].$4.length, (i) => i)..shuffle();
  }

  Future<void> _onTap(int option) async {
    if (_picked != null) return;
    if (option != _questions[_q].$5) {
      SoundManager.playNo();
      return;
    }
    SoundManager.playCorrect();
    setState(() => _picked = option);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_q < _questions.length - 1) {
      setState(() {
        _q++;
        _setQuestion();
      });
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final (title, isImage, clues, _, _) = _questions[_q];
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: MainAppBar(
        title: title,
        titleStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: LayoutBuilder(builder: (context, c) {
        final s = min(c.maxWidth / _designW, c.maxHeight / _designH);
        return Center(
          child: SizedBox(
            width: _designW * s,
            height: _designH * s,
            child: Stack(
              children: [
                Positioned(
                  left: 95 * s,
                  top: 67 * s,
                  width: 1310 * s,
                  child: Image.asset('$_path/img-board.png'),
                ),
                if (isImage)
                  for (int i = 0; i < clues.length; i++) _buildImageClue(clues[i], i, s)
                else
                  for (int i = 0; i < clues.length; i++) _buildTextClue(clues[i], i, s),
                for (int i = 0; i < _order.length; i++) _buildOption(i, s),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageClue(String image, int i, double s) {
    return Positioned(
      left: (295 + 470 * i) * s,
      top: 303 * s,
      width: 431 * s,
      height: 416 * s,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: _clueBorder, width: 2 * s),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset('$_path/$image', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTextClue(String text, int i, double s) {
    return Positioned(
      left: 295 * s,
      top: (302 + 150 * i) * s,
      width: 910 * s,
      height: 113 * s,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 26 * s),
        decoration: BoxDecoration(
          color: _clueFill,
          borderRadius: BorderRadius.circular(16 * s),
          border: Border.all(color: _clueBorder, width: 2 * s),
        ),
        child: Row(
          children: [
            Container(
              width: 66 * s,
              height: 66 * s,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: _brown, shape: BoxShape.circle),
              child: Text('${i + 1}', style: TextStyle(fontFamily: 'BMJUA', fontSize: 40 * s, color: Colors.white)),
            ),
            SizedBox(width: 20 * s),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'BMJUA', fontSize: 40 * s, color: _text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int i, double s) {
    final option = _order[i];
    final correct = _picked == option;
    return Positioned(
      left: 1468 * s,
      top: (133 + 384 * i) * s,
      width: 435 * s,
      height: 342 * s,
      child: GestureDetector(
        onTap: () => _onTap(option),
        child: AnimatedScale(
          scale: correct ? 1.08 : 1,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _picked != null && !correct ? 0.4 : 1,
            duration: const Duration(milliseconds: 200),
            child: Image.asset('$_path/${_questions[_q].$4[option]}', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
