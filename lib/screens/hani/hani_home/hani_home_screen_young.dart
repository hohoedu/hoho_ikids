import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/hani/drag_puzzle/drag_puzzle_screen.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_widgets/hani_contents.dart';
import 'package:hani_booki/screens/hani/quiz/quiz_screen.dart';
import 'package:hani_booki/services/hani/hani_drag_puzzle_service.dart';
import 'package:hani_booki/services/hani/hani_insung_service.dart';
import 'package:hani_booki/services/hani/hani_quiz_service.dart';
import 'package:hani_booki/services/hani/hani_rotate_service.dart';
import 'package:hani_booki/services/hani/hani_song_list_service.dart';
import 'package:hani_booki/services/mission/mission_list_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/mission/mission_button.dart';
import 'package:hani_booki/widgets/new_kidok_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';
import 'package:logger/logger.dart';

class HaniHomeScreenYoung extends StatefulWidget {
  final String keyCode;

  const HaniHomeScreenYoung({super.key, required this.keyCode});

  @override
  State<HaniHomeScreenYoung> createState() => _HaniHomeScreenYoungState();
}

class _HaniHomeScreenYoungState extends State<HaniHomeScreenYoung> with WidgetsBindingObserver, RouteAware {
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

  Future<void> _initMission() async {
    if (!Get.isRegistered<MissionController>()) {
      Get.put(MissionController());
    }
    await missionListService(widget.keyCode);
    final result = await missionSaveService(missionNum: 1, gb: 'attendance', keycode: widget.keyCode);

    if (result.success) {
      showStampDialog(widget.keyCode, isAttendance: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger().d('keyCode = ${widget.keyCode}');
    final haniData = haniHomeData.haniHomeData;
    String id = userData.userData!.id;
    String year = userData.userData!.year;
    final bool isSibling = userData.userData!.siblingCount == '1' ? false : true;
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Color(0xFFD2FFFE),
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFD2FFFE),
          ),
          child: Row(
            children: [
              // hani Main
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 윗줄 컨텐츠 3개
                        Row(
                          children: [
                            HaniContents(
                              imagePath: '${haniData['card']}',
                              lastTime: haniHomeData.haniLastTimeMap['card'] ?? '',
                              onTap: () async {
                                haniRotateService(id, widget.keyCode, year, haniHomeData.haniLastTimeMap['card'] ?? '');
                              },
                              type: 'card',
                            ),
                            HaniContents(
                              imagePath: '${haniData['quiz']}',
                              lastTime: haniHomeData.haniLastTimeMap['quiz'] ?? '',
                              onTap: () async {
                                await haniQuizService(id, widget.keyCode, year);
                                Get.to(() => QuizScreen(keyCode: widget.keyCode));
                              },
                              type: 'quiz',
                            ),
                            HaniContents(
                              imagePath: '${haniData['puz']}',
                              lastTime: haniHomeData.haniLastTimeMap['puz'] ?? '',
                              onTap: () async {
                                await haniDragPuzzleService(id, widget.keyCode, year);
                                Get.to(() => DragPuzzleScreen(keyCode: widget.keyCode));
                              },
                              type: 'puz_young',
                            ),
                          ],
                        ),
                        // 아랫줄 컨텐츠 2개
                        Row(
                          children: [
                            HaniContents(
                              imagePath: '${haniData['song']}',
                              lastTime: haniHomeData.haniLastTimeMap['song'] ?? '',
                              onTap: () {
                                haniSongListService(id, widget.keyCode, year);
                              },
                              type: 'song',
                            ),
                            HaniContents(
                              imagePath: '${haniData['insung']}',
                              lastTime: haniHomeData.haniLastTimeMap['insung'] ?? '',
                              onTap: () {
                                haniInsungService(id, widget.keyCode, year);
                              },
                              type: 'insung',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: screenWidth >= 1000 ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: screenWidth >= 1000 ? MainAxisAlignment.center : MainAxisAlignment.end,
                        children: [
                          MissionButton(keycode: widget.keyCode),
                          NewKidokButton(
                            type: 'hani',
                            keycode: widget.keyCode,
                            constraints: constraints,
                          ),
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
