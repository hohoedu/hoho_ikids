import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_widgets/hani_contents.dart';
import 'package:hani_booki/services/mission/mission_clear_service.dart';
import 'package:hani_booki/services/mission/mission_list_service.dart';
import 'package:hani_booki/services/hani/hani_erase_service.dart';
import 'package:hani_booki/services/hani/hani_flip_service.dart';
import 'package:hani_booki/services/hani/hani_goldenbell_service.dart';
import 'package:hani_booki/services/hani/hani_hanjasong_service.dart';
import 'package:hani_booki/services/hani/hani_insung_service.dart';
import 'package:hani_booki/services/hani/hani_puzzle_service.dart';
import 'package:hani_booki/services/hani/hani_song_service.dart';
import 'package:hani_booki/services/hani/hani_stroke_service.dart';
import 'package:hani_booki/services/hani/hani_story_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/kidok_button.dart';
import 'package:hani_booki/widgets/mission/mission_button.dart';
import 'package:hani_booki/widgets/new_kidok_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';
import 'package:hani_booki/widgets/star_count.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class HaniHomeScreen extends StatefulWidget {
  final String keyCode;

  const HaniHomeScreen({super.key, required this.keyCode});

  @override
  State<HaniHomeScreen> createState() => _HaniHomeScreenState();
}

class _HaniHomeScreenState extends State<HaniHomeScreen> with WidgetsBindingObserver, RouteAware {
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

  @override
  Widget build(BuildContext context) {
    final haniData = haniHomeData.haniHomeData;
    String id = userData.userData!.id;
    String year = userData.userData!.year;
    final bool isSibling = userData.userData!.siblingCount == '1' ? false : true;
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Color(0xFFFFDDE2),
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
          width: MediaQuery
              .of(context)
              .size
              .width * 0.9,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFFFDDE2),
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
                                path: '${haniData['song']}',
                                onTap: () {
                                  haniSongService(id, widget.keyCode, year);
                                }),
                            HaniContents(
                              path: '${haniData['story']}',
                              onTap: () {
                                haniStoryService(id, widget.keyCode, year);
                              },
                            ),
                            HaniContents(
                              path: '${haniData['insung']}',
                              onTap: () {
                                haniInsungService(id, widget.keyCode, year);
                              },
                            ),
                          ],
                        ),
                        // 아랫줄 컨텐츠 4개
                        Row(
                          children: [
                            HaniContents(
                              path: '${haniData['write']}',
                              onTap: () {
                                haniStrokeService(id, widget.keyCode, year);
                              },
                            ),
                            HaniContents(
                              path: '${haniData['card']}',
                              onTap: () {
                                haniFlipService(id, widget.keyCode, year);
                              },
                            ),
                            widget.keyCode.substring(0, 1) == 'Y'
                                ? HaniContents(
                              path: '${haniData['clean']}',
                              onTap: () {
                                haniEraseService(id, widget.keyCode, year);
                              },
                            )
                                : HaniContents(
                              path: '${haniData['puz']}',
                              onTap: () {
                                haniPuzzleService(id, widget.keyCode, year);
                              },
                            ),
                            widget.keyCode.substring(0, 1) == 'S'
                                ? HaniContents(
                              path: '${haniData['bell']}',
                              onTap: () {
                                bgmController.stopBgm();
                                haniGoldenbellService(id, widget.keyCode, year);
                              },
                            )
                                : HaniContents(
                              path: '${haniData['han']}',
                              onTap: () {
                                haniHanjaSongService(id, widget.keyCode, year);
                              },
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
