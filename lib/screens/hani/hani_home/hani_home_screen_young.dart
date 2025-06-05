import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/hani/drag_puzzle/drag_puzzle_screen.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_widgets/hani_contents.dart';
import 'package:hani_booki/screens/hani/quiz/quiz_screen.dart';
import 'package:hani_booki/services/hani/hani_drag_puzzle_service.dart';
import 'package:hani_booki/services/hani/hani_insung_service.dart';
import 'package:hani_booki/services/hani/hani_quiz_service.dart';
import 'package:hani_booki/services/hani/hani_rotate_service.dart';
import 'package:hani_booki/services/hani/hani_song_list_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/new_kidok_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';

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
                              path: '${haniData['card']}',
                              onTap: () async {
                                haniRotateService(id, widget.keyCode, year);
                              },
                            ),
                            HaniContents(
                              path: '${haniData['quiz']}',
                              onTap: () async {
                                await haniQuizService(id, widget.keyCode, year);
                                Get.to(() => QuizScreen(keyCode: widget.keyCode));
                              },
                            ),
                            HaniContents(
                              path: '${haniData['puz']}',
                              onTap: () async {
                                await haniDragPuzzleService(id, widget.keyCode, year);
                                Get.to(() => DragPuzzleScreen(keyCode: widget.keyCode));
                              },
                            ),
                          ],
                        ),
                        // 아랫줄 컨텐츠 2개
                        Row(
                          children: [
                            HaniContents(
                              path: '${haniData['song']}',
                              onTap: () {
                                haniSongListService(id, widget.keyCode, year);
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
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: screenWidth >= 1000 ? EdgeInsets.zero : EdgeInsets.only(bottom: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
