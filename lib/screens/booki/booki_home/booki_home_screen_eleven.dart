import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_booki_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/booki/booki_basket_service.dart';
import 'package:hani_booki/services/booki/booki_proviso_service.dart';
import 'package:hani_booki/services/booki/booki_song_service.dart';
import 'package:hani_booki/services/booki/booki_story_board_service.dart';
import 'package:hani_booki/services/booki/booki_sentence_service.dart';
import 'package:hani_booki/services/mission/mission_list_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/mission/mission_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';

class BookiHomeScreenEleven extends StatefulWidget {
  final String keyCode;

  const BookiHomeScreenEleven({super.key, required this.keyCode});

  @override
  State<BookiHomeScreenEleven> createState() => _BookiHomeScreenElevenState();
}

class _BookiHomeScreenElevenState extends State<BookiHomeScreenEleven> with WidgetsBindingObserver, RouteAware {
  final bgmController = Get.find<BgmController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final bookiHomeData = Get.find<BookiHomeDataController>();
  final userBookiData = Get.find<UserBookiDataController>();
  final userData = Get.find<UserDataController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    playBgm(widget.keyCode);
    _initMission();
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

  void playBgm(String keyCode) {
    if (keyCode.substring(0, 1) == 'J') {
      bgmController.playBgm('jaram');
    } else if (keyCode.substring(0, 1) == 'K') {
      bgmController.playBgm('kium');
    } else {
      bgmController.playBgm('mannam');
    }
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
    playBgm(widget.keyCode);
  }

  // 콘텐츠 화면이 위로 올라가면 메인 BGM 정지 (돌아오면 didPopNext에서 다시 재생)
  @override
  void didPushNext() {
    super.didPushNext();
    bgmController.stopBgm();
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
    String id = userData.userData!.id;
    String year = userData.userData!.year;
    final bool isSibling = userData.userData!.siblingCount == '1' ? false : true;
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Color(0xFFFFFDF0),
      appBar: MainAppBar(
        isContent: false,
        onTap: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: MainDrawer(
        isHome: false,
        type: 'booki',
        isSibling: isSibling,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFFFFDF0),
          ),
          child: Row(
            children: [
              // booki Main
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _tile('assets/images/song.png', () => bookiSongService(id, widget.keyCode, year)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _tile(
                                    'assets/images/basket.png',
                                    () => bookiBasketService(userData.userData!.id, widget.keyCode, userData.userData!.year),
                                    alignment: Alignment.bottomCenter,
                                  ),
                                  _tile(
                                    'assets/images/storyboard.png',
                                    () => bookiStoryBoardService(userData.userData!.id, widget.keyCode, userData.userData!.year),
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  _tile(
                                    'assets/images/clude.png',
                                    () => bookiProvisoService(userData.userData!.id, widget.keyCode, userData.userData!.year),
                                    alignment: Alignment.topCenter,
                                  ),
                                  _tile('assets/images/sentence.png', () => bookiSentenceService(userData.userData!.id, widget.keyCode, userData.userData!.year), alignment: Alignment.topCenter),
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
                  padding: screenWidth >= 1000 ? EdgeInsets.zero : EdgeInsets.only(bottom: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MissionButton(keycode: widget.keyCode),
                          NewStarCount(
                            keyCode: widget.keyCode,
                            type: 'booki',
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
