import 'package:flutter/material.dart';

// Android 전용 스플래시 (호글호글과 같은 방식)
// Android 12+ 시스템 스플래시는 로고를 작은 원 안에만 그려서, 시스템 스플래시는 비워 두고
// 첫 화면 위에 남색 배경 + 로고(launcher.png)를 크게 덮었다가 사라지게 함
class SplashScreen extends StatefulWidget {
  final Widget child; // 스플래시 뒤에서 미리 준비되는 첫 화면
  final Duration duration;

  const SplashScreen({super.key, required this.child, this.duration = const Duration(seconds: 2)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
              child: FractionallySizedBox(
                heightFactor: 0.7,
                child: Image.asset('assets/images/launcher.png', fit: BoxFit.contain),
              ),
            ),
          ),
      ],
    );
  }
}
