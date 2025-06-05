import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({Key? key, required this.child}) : super(key: key);

  @override
  _AppLifecycleHandlerState createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler> with WidgetsBindingObserver {
  late final BgmController _bgmController;

  @override
  void initState() {
    super.initState();
    // 라이프사이클 옵저버 등록
    WidgetsBinding.instance.addObserver(this);
    // GetX에서 이미 put 되어 있어야 하므로 find 호출
    _bgmController = Get.find<BgmController>();
  }

  @override
  void dispose() {
    // 옵저버 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 백그라운드(inactive/paused) 상태로 갈 때
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _bgmController.pauseBgm();
    }
    // 앱이 다시 포그라운드(resumed)로 들어올 때
    else if (state == AppLifecycleState.resumed) {
      _bgmController.resumeBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
