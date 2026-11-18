import 'package:flutter/material.dart';

// Android 전용 스플래시
// Android 12+ 시스템 스플래시는 큰 이미지를 못 넣어서, 시스템 스플래시 아이콘과 같은 크기(190dp)·같은 위치에
// 로고를 이어 그림 → 파란 화면과 로고가 한 화면처럼 이어짐 (res/drawable-xxxhdpi/android12splash.png 와 맞춤)
class SplashScreen extends StatefulWidget {
  final Widget child; // 스플래시 뒤에서 미리 준비되는 첫 화면
  final Duration duration;

  const SplashScreen({super.key, required this.child, this.duration = const Duration(seconds: 2)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _logoSize = 763 / 4; // splash_logo.png(xxxhdpi 763px) = 190.75dp
  bool _visible = true; // 페이드 아웃 시작
  bool _removed = false; // 페이드 끝나면 위젯 트리에서 뺌

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_removed)
          AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            onEnd: () => setState(() => _removed = true),
            child: Container(
              color: const Color(0xFF2E3192), // launcher.png(앱 아이콘) 배경 남색과 같게
              alignment: Alignment.center,
              // MyApp 이 상태바 높이만큼 아래로 밀어 두므로, 그 절반만큼 올려서 시스템 스플래시처럼 화면 정중앙에
              child: Transform.translate(
                offset: Offset(0, -MediaQuery.of(context).padding.top / 2),
                child: Image.asset('assets/images/launcher.png', width: _logoSize, height: _logoSize),
              ),
            ),
          ),
      ],
    );
  }
}
