import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/hani/relics/relics_widgets/spray_scratcher.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

class RelicsScreen extends StatefulWidget {
  const RelicsScreen({super.key});

  @override
  State<RelicsScreen> createState() => _RelicsScreenState();
}

class _RelicsScreenState extends State<RelicsScreen> {
  static const _gap = 16.0;

  // relics_frame.png(1542x938) 안쪽 투명 영역 비율
  static const _frameAspect = 1542 / 938;
  static const _innerL = 105 / 1542, _innerR = 107 / 1542, _innerT = 103 / 938, _innerB = 105 / 938;

  // shortcut: 샘플 문제 하드코딩(그림 속 한자 間 = 아래 보기), 서버 데이터 붙일 때 교체
  static const _choices = [
    (asset: 'assets/images/hani/relics/top_btn.png', correct: false), // 門
    (asset: 'assets/images/hani/relics/bottom_btn.png', correct: true), // 間
  ];

  int _round = 0; // 다시 하기 때 덮개를 새로 깔기 위한 키
  bool _cleared = false; // 다 긁어야 보기를 누를 수 있음
  bool _solved = false;
  int? _shaking; // 틀린 보기 흔들기
  int _shakeSeq = 0;

  void _onChoice(int i) {
    if (!_cleared || _solved) return;
    if (!_choices[i].correct) {
      SoundManager.playNo();
      setState(() {
        _shaking = i;
        _shakeSeq++;
      });
      return;
    }
    SoundManager.playCorrect();
    // shortcut: 샘플 문제 하나라 음성도 하나, 서버 데이터 붙일 때 문제별 음성으로 교체
    SoundManager.playVoice('assets/audio/voice/relics_correct.mp3');
    setState(() => _solved = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      lottieDialog(
        onReset: () {
          Get.back();
          setState(() {
            _round++;
            _cleared = _solved = false;
            _shaking = null;
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
    final safe = MediaQuery.paddingOf(context);

    final side = max(16.0, max(safe.left, safe.right) * 0.8);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MainAppBar(
        isContent: false,
        title: '모래 속에 숨겨진 그림과 한자를 찾아보세요.',
        titleStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/hani/relics/relics_bg.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(side, kToolbarHeight - 8, side, 8),
            child: LayoutBuilder(
              builder: (context, c) {
                // 액자는 남은 높이를 꽉 채우되, 버튼 자리로 가로 22%는 남김 (아이패드처럼 덜 길쭉한 화면 대비)
                final frameW = min(c.maxHeight * _frameAspect, (c.maxWidth - _gap) * 0.78);
                return Row(
                  children: [
                    SizedBox(width: frameW, child: Center(child: _buildFrame())),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: _gap),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < _choices.length; i++) _buildButton(i),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(int i) {
    Widget child = AnimatedScale(
      // 맞힌 보기는 살짝 커짐
      scale: _solved && _choices[i].correct ? 1.08 : 1,
      duration: const Duration(milliseconds: 200),
      child: Image.asset(_choices[i].asset),
    );
    if (_shaking == i) {
      child = TweenAnimationBuilder<double>(
        key: ValueKey(_shakeSeq),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        builder: (context, t, child) => Transform.translate(offset: Offset(sin(t * pi * 6) * (1 - t) * 12, 0), child: child),
        child: child,
      );
    }
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AspectRatio(
          aspectRatio: 603 / 406,
          child: GestureDetector(
            key: ValueKey('choice$i'),
            onTap: () => _onChoice(i),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildFrame() {
    return AspectRatio(
      aspectRatio: _frameAspect,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: w * _innerL,
                right: w * _innerR,
                top: h * _innerT,
                bottom: h * _innerB,
                child: SprayScratcher(
                  key: ValueKey(_round),
                  onThreshold: () => setState(() => _cleared = true),
                  // 기기 크기와 상관없이 같은 손놀림으로 긁히도록 영역 폭의 13%
                  brushSize: w * (1 - _innerL - _innerR) * 0.13,
                  threshold: 75,
                  coverAsset: 'assets/images/hani/relics/relics_scratch_bg.png',
                  child: Image.asset('assets/images/hani/relics/relics_sample.png', fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: Image.asset('assets/images/hani/relics/relics_frame.png', fit: BoxFit.fill)),
              ),
            ],
          );
        },
      ),
    );
  }
}
