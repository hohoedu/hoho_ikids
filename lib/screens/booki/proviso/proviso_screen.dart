import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_proviso_data.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/sound_button.dart';
import 'package:hani_booki/widgets/source_image.dart';

const _path = 'assets/images/booki/proviso';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

const _bg = Color(0xFFF6F9E5);
const _brown = Color(0xFF5B3A24);
const _clueFill = Color(0xFFFFF8EC);
const _clueBorder = Color(0xFFE9D8BD);
const _text = Color(0xFF3A3A3A);

/// 한 판에 내는 문제 수 (서버는 10개를 줌)
const _questionsPerGame = 7;

class ProvisoScreen extends StatefulWidget {
  /// [questions] 를 안 주면 bookiProvisoService 가 받아 둔 목록을 씀
  const ProvisoScreen({super.key, this.questions, this.random});

  final List<BookiProvisoData>? questions;
  final Random? random;

  @override
  State<ProvisoScreen> createState() => _ProvisoScreenState();
}

class _ProvisoScreenState extends State<ProvisoScreen> {
  late final Random _rand = widget.random ?? Random();
  late final List<BookiProvisoData> _all =
      widget.questions ?? Get.find<BookiProvisoDataController>().bookiProvisoDataList;

  // 이번 판에 낼 문제들(전체에서 랜덤 7개)과 지금 몇 번째인지
  late List<BookiProvisoData> _questions;
  int _q = 0;
  int? _picked; // 정답을 고른 뒤 다음 문제로 넘어가기 전까지 입력 잠금
  List<int> _order = []; // 인물 보기 배치 순서 (값 = 보기 인덱스, 0 이 정답)
  bool _ready = false; // 이번 문제 그림을 다 받았는지 (받기 전엔 로딩 표시)

  @visibleForTesting
  int get index => _q;
  @visibleForTesting
  BookiProvisoData get question => _questions[_q];

  List<String> _options(BookiProvisoData q) => [q.answerImg, q.wrongImg];

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
    return precacheSources([...question.imageClues, ..._options(question)], context);
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
    final q = _ready ? _questions[_q] : null;
    final isImage = q?.isImage ?? false;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: MainAppBar(
        title: isImage ? '단서를 보고 관련된 인물을 맞혀보세요.' : '단서를 보고 어떤 인물인지 맞혀보세요.',
        titleStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: LayoutBuilder(builder: (context, c) {
        final s = min(c.maxWidth / _designW, c.maxHeight / _designH);
        if (q == null) return const Center(child: CircularProgressIndicator(color: _brown));
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
                  for (int i = 0; i < q.imageClues.length; i++) _buildImageClue(q.imageClues[i], i, s)
                else
                  for (int i = 0; i < q.textClues.length; i++) _buildTextClue(q.textClues[i], i, s),
                for (int i = 0; i < _order.length; i++) _buildOption(i, s),
                // 몇 번째 문제인지 (두루마리 가운데 아래 빈자리, 양쪽 손잡이와 안 겹침)
                Positioned(
                  left: 95 * s,
                  width: 1310 * s,
                  bottom: 25 * s,
                  child: Center(child: Text('${_q + 1} / ${_questions.length}', style: _font(40 * s, _brown))),
                ),
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
        child: sourceImage(image, fit: BoxFit.cover),
      ),
    );
  }

  /// BMJUA 는 가운뎃점(3·1 운동) 모양이 비어 있어서 문장 완성처럼 나눔스퀘어라운드 사용
  TextStyle _font(double size, Color color) =>
      TextStyle(fontFamily: 'NANUM-EB', fontSize: size, color: color, height: 1.25);

  Widget _buildTextClue(BookiProvisoTextClue clue, int i, double s) {
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
              child: Text('${i + 1}', style: _font(40 * s, Colors.white)),
            ),
            SizedBox(width: 20 * s),
            Expanded(
              // 긴 단서(예: 손가락 한 마디가 짧은 손도장이 유명해요.)는 두 줄로
              child: Text(
                keepWords(clue.text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _font(36 * s, _text),
              ),
            ),
            SizedBox(width: 16 * s),
            SoundButton(voice: clue.voice, size: 70 * s),
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
            child: sourceImage(_options(_questions[_q])[option], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
