import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

const _path = 'assets/images/booki/story_board';

// 디자인 기준 캔버스(2000x924) 좌표. 화면 크기에 맞춰 비율로 스케일됨.
const _designW = 2000.0;
const _designH = 924.0;

const _bg = Color(0xFFF9DDF0);
const _cream = Color(0xFFFFF6E3);
const _caption = Color(0xFFF8F3E4);
const _pink = Color(0xFFF77FA3);
const _dash = Color(0xFFD9B9AC);
const _text = Color(0xFF3A3A3A);

// shortcut: 제인 구달(story22) 한 문제만 하드코딩, 다른 이야기가 생기면 서버 데이터로 교체
// 리스트 순서 = 정답 순서
const _scenes = [
  ('story22-1.png', '제인은 어렸을 때부터\n동물을 참 좋아했어요.'),
  ('story22-2.png', '제인은 아프리카에서 침팬지와\n지내며 그들을 지켜봤어요.'),
  ('story22-3.png', '침팬지가 나뭇가지를 사용해\n흰개미를 먹는 것을 발견했어요.'),
  ('story22-4.png', '동물을 괴롭히는 사람들에게\n그들을 존중해야 한다고 말했어요.'),
];

class StoryBoardScreen extends StatefulWidget {
  const StoryBoardScreen({super.key});

  @override
  State<StoryBoardScreen> createState() => _StoryBoardScreenState();
}

class _StoryBoardScreenState extends State<StoryBoardScreen> {
  // 아래 카드 배치 순서 (값 = _scenes 인덱스)
  late List<int> _deck;

  // 채워진 칸 수. 칸은 앞에서부터 순서대로만 채워짐.
  int _filled = 0;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    // 1번은 예시로 미리 채워두고, 나머지만 섞어서 문제로 냄
    _deck = List.generate(_scenes.length - 1, (i) => i + 1)..shuffle();
    _filled = 1;
  }

  void _onDrop(int scene, int slot) {
    if (scene != slot) {
      SoundManager.playNo(); // 오답은 받지 않으므로 카드가 원래 자리로 돌아감
      return;
    }
    SoundManager.playCorrect();
    setState(() => _filled++);

    if (_filled == _scenes.length) {
      lottieDialog(
        onReset: () {
          Get.back();
          setState(_shuffle);
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
        title: ' ',
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
                  left: 0,
                  right: 0,
                  top: 40 * s,
                  child: Text(
                    '사건이 일어난 순서에 맞춰 스토리보드를 완성해 보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'BMJUA', fontSize: 46 * s, color: _text),
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
                          child: Image.asset('$_path/${_scenes[i].$1}', fit: BoxFit.cover),
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
          Image.asset('$_path/${_scenes[scene].$1}', height: 268 * s, width: double.infinity, fit: BoxFit.cover),
          Expanded(
            child: Center(
              child: Text(
                _scenes[scene].$2,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'NANUM-B', fontSize: 28 * s, height: 1.35, color: _text),
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
