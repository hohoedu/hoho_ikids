import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_sentence_data.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/sound_button.dart';
import 'package:hani_booki/widgets/source_image.dart';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

const _bg = Color(0xFFF1EEFD);
const _purple = Color(0xFF8577E3);
const _purpleDark = Color(0xFF6A5BC9);
const _text = Color(0xFF3A3A3A);

/// 한 판에 내는 문제 수 (서버는 10개를 줌)
const _questionsPerGame = 7;

class SentenceScreen extends StatefulWidget {
  /// [questions] 를 안 주면 bookiSentenceService 가 받아 둔 목록을 씀
  const SentenceScreen({super.key, this.questions, this.random});

  final List<BookiSentenceData>? questions;
  final Random? random;

  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen> {
  late final Random _rand = widget.random ?? Random();
  late final List<BookiSentenceData> _all =
      widget.questions ?? Get.find<BookiSentenceDataController>().bookiSentenceDataList;

  // 이번 판에 낼 문제들(전체에서 랜덤 7개)과 지금 몇 번째인지
  late List<BookiSentenceData> _questions;
  int _q = 0;
  int? _picked; // 정답을 고른 뒤 다음 문제로 넘어가기 전까지 입력 잠금
  List<int> _order = []; // 보기 배치 순서 (값 = 보기 인덱스, 0 이 정답)
  bool _ready = false; // 이번 문제 그림을 다 받았는지 (받기 전엔 로딩 표시)

  @visibleForTesting
  int get index => _q;
  @visibleForTesting
  BookiSentenceData get question => _questions[_q];

  List<BookiSentenceOption> _options(BookiSentenceData q) => [q.answer, q.wrong];

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _questions = (List.of(_all)..shuffle(_rand)).take(_questionsPerGame).toList();
    _q = 0;
    // precacheImage 가 context 를 쓰므로 첫 프레임 뒤에 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _setQuestion());
  }

  /// 이번 문제 그림을 받은 뒤 보여 주고, 다음 문제 그림은 미리 받아 둠
  Future<void> _setQuestion() async {
    setState(() {
      _picked = null;
      _order = [0, 1]..shuffle(_rand);
      _ready = false;
    });
    // 인터넷이 느려도 10초 뒤엔 시작 (못 받은 그림은 Image가 이어서 받음)
    await _precache(_q).timeout(const Duration(seconds: 10), onTimeout: () => []);
    if (!mounted) return;
    setState(() => _ready = true);
    if (_q + 1 < _questions.length) _precache(_q + 1);
  }

  Future<List<void>> _precache(int q) {
    final question = _questions[q];
    return precacheSources([question.img, question.answer.img, question.wrong.img], context);
  }

  Future<void> _onTap(int option) async {
    if (_picked != null) return;
    if (option != 0) {
      SoundManager.playNo();
      return;
    }
    SoundManager.playCorrect();
    SoundManager.stopVoice();
    setState(() => _picked = option);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_q < _questions.length - 1) {
      _q++;
      _setQuestion();
      return;
    }
    lottieDialog(
      onReset: () {
        Get.back();
        _newGame();
      },
      onMain: () {
        Get.back();
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        final sentenceStyle = TextStyle(fontFamily: 'NANUM-EB', fontSize: 72 * s, height: 1.6, color: _text);
        if (!_ready) return const Center(child: CircularProgressIndicator(color: _purple));
        final q = _questions[_q];
        final options = _options(q);
        return Center(
          child: SizedBox(
            width: _designW * s,
            height: _designH * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 몇 번째 문제인지 (앱바 제목과 안 겹치게 문장 위 빈자리)
                Positioned(
                  right: 50 * s,
                  top: 150 * s,
                  child: Text(
                    '${_q + 1} / ${_questions.length}',
                    style: TextStyle(fontFamily: 'NANUM-EB', fontSize: 40 * s, color: _purple),
                  ),
                ),
                Positioned(
                  left: 215 * s,
                  top: 190 * s,
                  width: 530 * s,
                  child: sourceImage(q.img),
                ),
                // 문장 읽기: 인물 그림과 문장 사이, 문장 첫 줄 높이 (문장 top 270 + 첫 줄 높이 72*1.6 의 절반 - 버튼 절반)
                Positioned(
                  left: 780 * s,
                  top: (270 + 72 * 1.6 / 2 - 45) * s,
                  child: SoundButton(voice: q.voice, size: 90 * s),
                ),
                Positioned(
                  left: 900 * s,
                  top: 270 * s,
                  width: 1050 * s,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: q.before),
                      WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildBlank(s)),
                      TextSpan(text: q.after),
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
        _picked == null ? '?' : _options(_questions[_q])[_picked!].word,
        style: TextStyle(fontFamily: 'NANUM-EB', fontSize: _picked == null ? 64 * s : 58 * s, color: Colors.white),
      ),
    );
  }

  // shortcut: 책상 이미지가 없어서 시안을 보고 코드로 그림, 디자인 이미지 받으면 Image.asset으로 교체
  Widget _buildTable(double s) {
    return Positioned(
      left: 15 * s,
      right: 15 * s,
      top: 680 * s,
      bottom: -60 * s,
      child: const CustomPaint(painter: _TablePainter()),
    );
  }

  /// 보기 버튼 + 스티커를 합친 윤곽 그대로 아래에 진한 보라 그림자를 깔아 줌
  Widget _withShadow(double s, Widget child) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: 13 * s,
          bottom: -13 * s,
          child: ColorFiltered(colorFilter: const ColorFilter.mode(_purpleDark, BlendMode.srcIn), child: child),
        ),
        Positioned.fill(child: child),
      ],
    );
  }

  /// 투명 배경 그림에 흰 스티커 테두리: 흰 실루엣을 둥글게 돌려 찍어 [width]만큼 부풀림.
  /// 조각 사이 좁은 틈도 메워져서 한 장짜리 스티커처럼 보임
  Widget _sticker(String src, double width) {
    final image = sourceImage(src);
    const steps = 24;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var k = 0; k < steps; k++)
          Transform.translate(
            offset: Offset(cos(2 * pi * k / steps), sin(2 * pi * k / steps)) * width,
            child: ColorFiltered(colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), child: image),
          ),
        image,
      ],
    );
  }

  Widget _buildOption(int i, BookiSentenceOption option, double s) {
    final (:word, img: sticker) = option;
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
            child: _withShadow(
              s,
              Stack(
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
                      ),
                      child:
                          Text(word, style: TextStyle(fontFamily: 'NANUM-EB', fontSize: 66 * s, color: Colors.white)),
                    ),
                  ),
                  if (sticker.isNotEmpty)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 245 * s,
                      child: _sticker(sticker, 10 * s),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 원목 테이블: 양 끝이 둥근 위판(판자 3장, 이음매·나뭇결) + 두께 + 아래 세로 판자 몸통
class _TablePainter extends CustomPainter {
  const _TablePainter();

  static const _light = Color(0xFFF3C98D);
  static const _mid = Color(0xFFE8B274);
  static const _seam = Color(0xFFCB8F52);
  static const _outline = Color(0xFFB97B3F);
  static const _highlight = Color(0xFFFBE1B5);
  static const _edge = Color(0xFFDDA265); // 위판 앞쪽 두께

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final line = h * 0.012;
    final topH = h * 0.66; // 위판 높이
    final edge = h * 0.05; // 위판 두께

    // 아래 몸통: 위판보다 안쪽으로 들어간 세로 판자
    final apron = Rect.fromLTRB(w * 0.035, topH, w * 0.965, h);
    canvas.drawRect(apron, Paint()..color = _mid);
    final apronLine = Paint()
      ..color = _seam
      ..strokeWidth = line;
    for (var x = apron.left + w * 0.07; x < apron.right; x += w * 0.07) {
      canvas.drawLine(Offset(x, topH), Offset(x, h), apronLine);
    }
    canvas.drawRect(
        apron,
        Paint()
          ..color = _outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = line * 1.5);

    // 위판 모양: 위쪽 모서리는 크게, 아래쪽은 작게 둥글게
    RRect top(double bottom) => RRect.fromLTRBAndCorners(
          0,
          0,
          w,
          bottom,
          topLeft: Radius.elliptical(w * 0.12, topH * 0.6),
          topRight: Radius.elliptical(w * 0.12, topH * 0.6),
          bottomLeft: Radius.elliptical(w * 0.04, topH * 0.4),
          bottomRight: Radius.elliptical(w * 0.04, topH * 0.4),
        );

    // 두께: 진한 판을 먼저 깔고 그 위에 윗면
    final body = top(topH);
    canvas.drawRRect(body, Paint()..color = _edge);
    final face = top(topH - edge);
    canvas.drawRRect(
      face,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_light, _mid],
        ).createShader(face.outerRect),
    );

    canvas.save();
    canvas.clipRRect(face);
    final seam = Paint()
      ..color = _seam
      ..strokeWidth = line * 1.3;
    final shine = Paint()
      ..color = _highlight
      ..strokeWidth = line;
    final faceH = topH - edge;
    // 가로 판자 이음선 2줄 (아래에 밝은 줄을 붙여 홈처럼 보이게)
    final rows = [0.0, faceH * 0.36, faceH * 0.68, faceH];
    for (final y in rows.sublist(1, 3)) {
      canvas.drawLine(Offset(0, y), Offset(w, y), seam);
      canvas.drawLine(Offset(0, y + line * 1.5), Offset(w, y + line * 1.5), shine);
    }
    // 판자마다 엇갈린 세로 이음매
    const joints = [
      [0.46],
      [0.22, 0.71],
      [0.38, 0.86],
    ];
    for (var r = 0; r < 3; r++) {
      for (final x in joints[r]) {
        canvas.drawLine(Offset(w * x, rows[r]), Offset(w * x, rows[r + 1]), seam);
      }
    }
    // 은은한 나뭇결
    final grain = Paint()
      ..color = _seam.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = line * 0.8;
    for (final (x, y, len) in [
      (0.08, 0.2, 0.18),
      (0.62, 0.16, 0.2),
      (0.3, 0.52, 0.16),
      (0.78, 0.5, 0.14),
      (0.12, 0.84, 0.2),
      (0.55, 0.82, 0.18)
    ]) {
      final cy = faceH * y, gh = faceH * 0.04;
      canvas.drawPath(
        Path()
          ..moveTo(w * x, cy)
          ..quadraticBezierTo(w * (x + len / 2), cy - gh, w * (x + len), cy)
          ..moveTo(w * x, cy + gh)
          ..quadraticBezierTo(w * (x + len / 2), cy, w * (x + len), cy + gh),
        grain,
      );
    }
    // 위쪽 가장자리 밝은 테
    canvas.drawRRect(
      top(topH - edge).deflate(line * 2),
      Paint()
        ..color = _highlight.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = line,
    );
    canvas.restore();

    // 바깥 테두리
    canvas.drawRRect(
      body,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = line * 1.8,
    );
  }

  @override
  bool shouldRepaint(_TablePainter old) => false;
}
