import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_story_board_data.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/sound_button.dart';
import 'package:hani_booki/widgets/source_image.dart';

const _designW = 2000.0;
const _designH = 924.0;

const _bg = Color(0xFFF9DDF0);
const _cream = Color(0xFFFFF6E3);
const _caption = Color(0xFFF8F3E4);
const _pink = Color(0xFFF77FA3);
const _dash = Color(0xFFD9B9AC);
const _text = Color(0xFF3A3A3A);

const _storiesPerGame = 7;

class StoryBoardScreen extends StatefulWidget {
  /// [stories] 를 안 주면 bookiStoryBoardService 가 받아 둔 목록을 씀
  const StoryBoardScreen({super.key, this.stories, this.random});

  final List<BookiStoryBoardData>? stories;
  final Random? random;

  @override
  State<StoryBoardScreen> createState() => _StoryBoardScreenState();
}

class _StoryBoardScreenState extends State<StoryBoardScreen> {
  late final Random _rand = widget.random ?? Random();
  late final List<BookiStoryBoardData> _all =
      widget.stories ?? Get.find<BookiStoryBoardDataController>().bookiStoryBoardDataList;

  // 이번 판에 낼 이야기들(전체에서 랜덤 7개)과 지금 몇 번째인지
  late List<BookiStoryBoardData> _stories;
  int _round = 0;

  List<BookiStoryScene> get _scenes => _stories[_round].scenes;

  // 아래 카드 배치 순서 (값 = _scenes 인덱스)
  List<int> _deck = [];

  // 채워진 칸 수. 칸은 앞에서부터 순서대로만 채워짐.
  int _filled = 0;

  // 이번 이야기 그림을 다 받았는지 (받기 전엔 로딩 표시)
  bool _ready = false;

  @visibleForTesting
  int get round => _round;
  @visibleForTesting
  List<BookiStoryScene> get scenes => _scenes;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _stories = (List.of(_all)..shuffle(_rand)).take(_storiesPerGame).toList();
    _round = 0;
    // precacheImage 가 context 를 쓰므로 첫 프레임 뒤에 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  /// 이번 이야기 그림을 받은 뒤 시작하고, 다음 이야기 그림은 미리 받아 둠
  Future<void> _startRound() async {
    setState(() {
      // 1번은 예시로 미리 채워두고, 나머지만 섞어서 문제로 냄
      _deck = List.generate(_scenes.length - 1, (i) => i + 1)..shuffle(_rand);
      _filled = 1;
      _ready = false;
    });
    // 인터넷이 느려도 10초 뒤엔 시작 (못 받은 그림은 Image가 이어서 받음)
    await _precache(_round).timeout(const Duration(seconds: 10), onTimeout: () => []);
    if (!mounted) return;
    setState(() => _ready = true);
    if (_round + 1 < _stories.length) _precache(_round + 1);
  }

  Future<List<void>> _precache(int round) => precacheSources(_stories[round].scenes.map((e) => e.img), context);

  void _onDrop(int scene, int slot) {
    if (scene != slot) {
      SoundManager.playNo(); // 오답은 받지 않으므로 카드가 원래 자리로 돌아감
      return;
    }
    SoundManager.playCorrect();
    setState(() => _filled++);

    if (_filled < _scenes.length) return;
    SoundManager.stopVoice();
    if (_round + 1 < _stories.length) {
      // 완성된 이야기를 잠깐 보여 준 뒤 다음 이야기
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _round++;
        _startRound();
      });
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: MainAppBar(
        title: '사건이 일어난 순서에 맞춰 스토리보드를 완성해 보세요.',
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
            child: !_ready
                ? const Center(child: CircularProgressIndicator(color: _pink))
                : Stack(
                    children: [
                      // 몇 번째 이야기인지
                      Positioned(
                        // 앱바 제목과 안 겹치게 1번 칸 왼쪽 빈자리
                        left: 40 * s,
                        top: 150 * s,
                        child: Text(
                          '${_round + 1} / ${_stories.length}',
                          style: TextStyle(fontFamily: 'BMJUA', fontSize: 40 * s, color: _pink),
                        ),
                      ),
                      for (int i = 0; i < _scenes.length; i++) ...[
                        _buildSlot(i, s),
                        if (i > 0)
                          Positioned(
                            left: (535 + 428 * (i - 1)) * s,
                            top: 250 * s,
                            child: Icon(Icons.chevron_right_rounded, size: 80 * s, color: _pink.withValues(alpha: 0.6)),
                          ),
                      ],
                      for (int i = 0; i < _deck.length; i++) _buildCard(i, s),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildSlot(int i, double s) {
    final radius = BorderRadius.circular(28 * s);
    return Positioned(
      left: (185 + 428 * i) * s,
      top: 135 * s,
      width: 345 * s,
      height: 270 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 40 * s,
            child: DragTarget<int>(
              onWillAcceptWithDetails: (_) => i == _filled, // 다음 칸에만 놓을 수 있음
              onAcceptWithDetails: (d) => _onDrop(d.data, i),
              builder: (context, candidate, _) => AnimatedScale(
                scale: candidate.isEmpty ? 1 : 1.05,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius: radius,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8 * s, offset: Offset(0, 3 * s))],
                  ),
                  child: i < _filled
                      ? ClipRRect(
                          borderRadius: radius,
                          child: sourceImage(_scenes[i].img, fit: BoxFit.cover),
                        )
                      : Padding(
                          padding: EdgeInsets.all(14 * s),
                          child: CustomPaint(
                            painter: _DashedRRectPainter(radius: 20 * s, strokeWidth: 3 * s),
                            child: Center(
                              child: Text('?', style: TextStyle(fontFamily: 'BMJUA', fontSize: 64 * s, color: _dash)),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 90 * s,
              height: 90 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _pink,
                shape: BoxShape.circle,
                border: Border.all(color: _cream, width: 8 * s),
              ),
              child: Text('${i + 1}', style: TextStyle(fontFamily: 'BMJUA', fontSize: 44 * s, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int i, double s) {
    final scene = _deck[i];
    final placed = scene < _filled;
    final card = Container(
      width: 433 * s,
      height: 404 * s,
      decoration: BoxDecoration(
        color: _caption,
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white, width: 6 * s),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8 * s, offset: Offset(0, 3 * s))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: sourceImage(_scenes[scene].img, height: 220 * s, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 10 * s,
                  top: 10 * s,
                  child: SoundButton(voice: _scenes[scene].voice, size: 64 * s),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              child: Center(
                child: Text(
                  keepWords(_scenes[scene].text),
                  textAlign: TextAlign.center,
                  // 폰에서도 읽히게 크고 굵게, 긴 문장(예: 갈라파고스 제도에서…)은 3줄까지
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'NANUM-EB', fontSize: 36 * s, height: 1.3, color: _text),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Positioned(
      left: (_designW - 433 - 472 * (_deck.length - 1)) / 2 * s + 472 * i * s, // 카드 묶음 가운데 정렬
      top: 462 * s,
      child: placed
          ? Opacity(opacity: 0.35, child: card)
          : Draggable<int>(
              data: scene,
              feedback: Material(color: Colors.transparent, child: card),
              childWhenDragging: Opacity(opacity: 0.35, child: card),
              child: card,
            ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius, strokeWidth;

  _DashedRRectPainter({required this.radius, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _dash
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    final dash = strokeWidth * 5, gap = strokeWidth * 4;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.radius != radius || old.strokeWidth != strokeWidth;
}
