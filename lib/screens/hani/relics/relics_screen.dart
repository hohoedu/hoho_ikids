import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hani_booki/screens/hani/relics/relics_widgets/spray_scratcher.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';

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
                            _buildButton('assets/images/hani/relics/top_btn.png'),
                            _buildButton('assets/images/hani/relics/bottom_btn.png'),
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

  Widget _buildButton(String asset) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AspectRatio(aspectRatio: 603 / 406, child: Image.asset(asset)),
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
