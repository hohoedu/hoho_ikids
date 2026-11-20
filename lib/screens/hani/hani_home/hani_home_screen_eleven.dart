import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/hani/hani_cooking_service.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_screen.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_screen.dart';
import 'package:hani_booki/services/hani/hani_relics_service.dart';
import 'package:hani_booki/services/hani/hani_song_list_service.dart';
import 'package:hani_booki/services/mission/mission_list_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/mission/mission_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';
import 'package:logger/logger.dart';

class HaniHomeScreenEleven extends StatefulWidget {
  final String keyCode;

  const HaniHomeScreenEleven({super.key, required this.keyCode});

  @override
  State<HaniHomeScreenEleven> createState() => _HaniHomeScreenElevenState();
}

class _HaniHomeScreenElevenState extends State<HaniHomeScreenEleven> with WidgetsBindingObserver, RouteAware {
  final bgmController = Get.find<BgmController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final haniHomeData = Get.find<HaniHomeDataController>();
  final userHaniData = Get.find<UserHaniDataController>();
  final userData = Get.find<UserDataController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bgmController.playBgm('hani');
    _initMission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    bgmController.playBgm('hani');
  }

  // 콘텐츠 화면이 위로 올라가면 메인 BGM 정지 (돌아오면 didPopNext에서 다시 재생)
  @override
  void didPushNext() {
    super.didPushNext();
    bgmController.stopBgm();
  }

  Future<void> _initMission() async {
    if (!Get.isRegistered<MissionController>()) {
      Get.put(MissionController(), permanent: true);
    } else {
      Get.find<MissionController>().reset();
    }

    await missionListService(widget.keyCode);

    final result = await missionSaveService(missionNum: 1, gb: 'attendance', keycode: widget.keyCode);
    if (result.success) {
      showStampDialog(widget.keyCode, isAttendance: true);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final missionController = Get.find<MissionController>();
    final missions = [
      missionController.attendanceMission,
      missionController.contentMission,
    ];

    final hasUnclearedMission = missions.any(
      (m) => m != null && m.isCompleted && m.isCleared == 'N',
    );

    if (hasUnclearedMission) {
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: false,
        isScrollControlled: true,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        builder: (_) => MissionBottomSheet(keycode: widget.keyCode, autoTrigger: true),
      );
    }
  }

  Widget _tile(String asset, VoidCallback onTap, {Alignment alignment = Alignment.center}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(alignment: alignment, child: Image.asset(asset, fit: BoxFit.contain)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String id = userData.userData!.id;
    final String year = userData.userData!.year;
    final bool isSibling = userData.userData!.siblingCount == '1' ? false : true;
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: const Color(0xFFFFF0F6),
      appBar: MainAppBar(
        isPortraitMode: true,
        isContent: false,
        onTap: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: MainDrawer(
        isHome: false,
        type: 'hani',
        isSibling: isSibling,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: double.infinity,
          child: Row(
            children: [
              // hani Main: 동요 메들리(세로) + 2x2 콘텐츠
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _tile('assets/images/hani/song.png', () => haniSongListService(id, widget.keyCode, year)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _tile(
                                      'assets/images/hani/cook.png', () => haniCookingService(id, widget.keyCode, year),
                                      alignment: Alignment.bottomCenter),
                                  _tile(
                                      'assets/images/hani/find.png', () => haniRelicsService(id, widget.keyCode, year),
                                      alignment: Alignment.bottomCenter),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  _tile('assets/images/hani/hanipang.png',
                                      () => Get.to(() => HaniPangScreen(keyCode: widget.keyCode)),
                                      alignment: Alignment.topCenter),
                                  // TODO: 서버 준비되면 haniRunService(id, widget.keyCode, year) 로 교체 (지금은 앱 임시 목록)
                                  _tile('assets/images/hani/hanirun.png',
                                      () => Get.to(() => HaniRunScreen(keyCode: widget.keyCode)),
                                      alignment: Alignment.topCenter),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: screenWidth >= 1000 ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MissionButton(keycode: widget.keyCode),
                          NewStarCount(
                            keyCode: widget.keyCode,
                            type: 'hani',
                            constraints: constraints,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    bgmController.stopBgm();
    super.dispose();
  }
}
