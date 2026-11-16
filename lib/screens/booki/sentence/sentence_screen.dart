import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

const _path = 'assets/images/booki/sentence';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

const _bg = Color(0xFFF1EEFD);
const _purple = Color(0xFF8577E3);
const _purpleDark = Color(0xFF6A5BC9);
const _wood = Color(0xFFEDB873);
const _woodDark = Color(0xFFCF904F);
const _text = Color(0xFF3A3A3A);

// shortcut: 뉴턴(inmul-16) 한 문제만 하드코딩, 다른 인물이 생기면 서버 데이터로 교체
// (인물 이미지, 빈칸 앞 문장, 빈칸 뒤 문장, 보기들(단어, 스티커), 정답 인덱스)
const _questions = [
  (
    'inmul-16.png',
    '뉴턴은 떨어지는 사과를 보고\n',
    ' 을 발견했어요.',
    [
      ('만유인력', 'a-16-1.png'),
      ('나침반', null), // TODO: 나침반 스티커 이미지 받으면 추가
    ],
    0,
  ),
];

class SentenceScreen extends StatefulWidget {
  const SentenceScreen({super.key});

  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen> {
  int _q = 0;
  int? _picked; // 정답을 고른 뒤 다음 문제로 넘어가기 전까지 입력 잠금
  late List<int> _order; // 보기 배치 순서 (값 = 보기 인덱스)

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
    final (person, before, after, options, _) = _questions[_q];
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: MainAppBar(
        title: '빈 칸에 알맞은 단어를 골라 문장을 완성해 보세요.',
        titleStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: LayoutBuilder(builder: (context, c) {
        final s = min(c.maxWidth / _designW, c.maxHeight / _designH);
        final sentenceStyle = TextStyle(fontFamily: 'BMJUA', fontSize: 72 * s, height: 1.6, color: _text);
        return Center(
          child: SizedBox(
            width: _designW * s,
            height: _designH * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 215 * s,
                  top: 190 * s,
                  width: 530 * s,
                  child: Image.asset('$_path/$person'),
                ),
                Positioned(
                  left: 900 * s,
                  top: 270 * s,
                  width: 1050 * s,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: before),
                      WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildBlank(s)),
                      TextSpan(text: after),
                    ]),
                    style: sentenceStyle,
                  ),
                ),
                _buildTable(s),
                for (int i = 0; i < _order.length; i++) _buildOption(i, options[_order[i]], s),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBlank(double s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 362 * s,
      height: 122 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _purple,
        borderRadius: BorderRadius.circular(32 * s),
      ),
      child: Text(
        _picked == null ? '?' : _questions[_q].$4[_picked!].$1,
        style: TextStyle(fontFamily: 'BMJUA', fontSize: _picked == null ? 64 * s : 58 * s, color: Colors.white),
      ),
    );
  }

  // shortcut: 책상 이미지가 없어서 코드로 그림, 디자인 이미지 받으면 Image.asset으로 교체
  Widget _buildTable(double s) {
    final top = Radius.elliptical(260 * s, 70 * s);
    return Positioned(
      left: 15 * s,
      right: 15 * s,
      top: 680 * s,
      bottom: -60 * s,
      child: Container(
        decoration: BoxDecoration(
          color: _woodDark,
          borderRadius: BorderRadius.vertical(top: top),
        ),
        padding: EdgeInsets.only(bottom: 120 * s),
        child: Container(
          decoration: BoxDecoration(
            color: _wood,
            borderRadius: BorderRadius.vertical(top: top, bottom: Radius.elliptical(260 * s, 40 * s)),
            border: Border.all(color: _woodDark, width: 5 * s),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int i, (String, String?) option, double s) {
    final (word, sticker) = option;
    final index = _order[i];
    final correct = _picked == index;
    return Positioned(
      left: (290 + 750 * i) * s,
      top: 650 * s,
      width: 630 * s,
      height: 240 * s,
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: AnimatedScale(
          scale: correct ? 1.06 : 1,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _picked != null && !correct ? 0.4 : 1,
            duration: const Duration(milliseconds: 200),
            child: Stack(
              children: [
                Positioned(
                  left: 13 * s,
                  top: 54 * s,
                  width: 605 * s,
                  height: 131 * s,
                  child: Container(
                    padding: EdgeInsets.only(left: 230 * s),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(40 * s),
                      boxShadow: [BoxShadow(color: _purpleDark, offset: Offset(0, 13 * s))],
                    ),
                    child: Text(word, style: TextStyle(fontFamily: 'BMJUA', fontSize: 66 * s, color: Colors.white)),
                  ),
                ),
                if (sticker != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 245 * s,
                    child: Image.asset('$_path/$sticker'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
