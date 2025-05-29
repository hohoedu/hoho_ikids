import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_booki_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/booki/booki_home/booki_home_widgets/booki_bottom_contents.dart';
import 'package:hani_booki/screens/booki/booki_home/booki_home_widgets/booki_top_contents.dart';
import 'package:hani_booki/services/booki/booki_find_diff_service.dart';
import 'package:hani_booki/services/booki/booki_goldenbell_service.dart';
import 'package:hani_booki/services/booki/booki_match_service.dart';
import 'package:hani_booki/services/booki/booki_song_service.dart';
import 'package:hani_booki/services/booki/booki_story_service.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/kidok_button.dart';
import 'package:hani_booki/widgets/new_kidok_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';
import 'package:hani_booki/widgets/star_count.dart';
import 'package:logger/logger.dart';

class BookiHomeScreen extends StatefulWidget {
  final String keyCode;

  const BookiHomeScreen({super.key, required this.keyCode});

  @override
  State<BookiHomeScreen> createState() => _BookiHomeScreenState();
}

class _BookiHomeScreenState extends State<BookiHomeScreen> with WidgetsBindingObserver, RouteAware {
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

  @override
  Widget build(BuildContext context) {
    final bookiData = bookiHomeData.bookiHomeData;
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
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 윗줄 컨텐츠 2개
                        Row(
                          children: [
                            BookiTopContents(
                              imagePath: '${bookiData['story']}',
                              onTap: () => bookiStoryService(id, widget.keyCode, year),
                            ),
                            BookiTopContents(
                              imagePath: '${bookiData['song']}',
                              onTap: () => bookiSongService(id, widget.keyCode, year),
                            ),
                          ],
                        ),
                        // 아랫줄 컨텐츠 3개
                        Row(
                          children: [
                            BookiBottomContents(
                              imagePath: '${bookiData['bell']}',
                              color: gold,
                              onTap: () {
                                bgmController.stopBgm();
                                bookiGoldenbellService(id, widget.keyCode, year);
                              },
                            ),
                            BookiBottomContents(
                              imagePath: '${bookiData['find']}',
                              color: amethyst,
                              onTap: () => bookiFindDiffService(id, widget.keyCode, year),
                            ),
                            BookiBottomContents(
                              imagePath: '${bookiData['img']}',
                              color: emerald,
                              onTap: () => bookiMatchService(id, widget.keyCode, year),
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
                  padding: screenWidth >= 1000
                      ? EdgeInsets.zero
                      : EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NewKidokButton(
                        type: 'booki',
                        keycode: widget.keyCode,
                      ),
                      NewStarCount(
                        keyCode: widget.keyCode,
                        type: 'booki',
                      ),
                    ],
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
