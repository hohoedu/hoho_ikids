import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_widgets/hani_contents.dart';
import 'package:hani_booki/services/hani/hani_erase_service.dart';
import 'package:hani_booki/services/hani/hani_flip_service.dart';
import 'package:hani_booki/services/hani/hani_goldenbell_service.dart';
import 'package:hani_booki/services/hani/hani_goldenbell_su_service.dart';
import 'package:hani_booki/services/hani/hani_hanjasong_service.dart';
import 'package:hani_booki/services/hani/hani_insung_service.dart';
import 'package:hani_booki/services/hani/hani_make_card_service.dart';
import 'package:hani_booki/services/hani/hani_puzzle_service.dart';
import 'package:hani_booki/services/hani/hani_quiz_service.dart';
import 'package:hani_booki/services/hani/hani_song_list_service.dart';
import 'package:hani_booki/services/hani/hani_song_service.dart';
import 'package:hani_booki/services/hani/hani_storke_service.dart';
import 'package:hani_booki/services/hani/hani_story_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/kidok_button.dart';
import 'package:hani_booki/widgets/new_kidok_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';
import 'package:hani_booki/widgets/star_count.dart';
import 'package:logger/logger.dart';

class HaniHomeScreenSu extends StatefulWidget {
  final String keyCode;

  const HaniHomeScreenSu({super.key, required this.keyCode});

  @override
  State<HaniHomeScreenSu> createState() => _HaniHomeScreenSuState();
}

class _HaniHomeScreenSuState extends State<HaniHomeScreenSu> {
  final bgmController = Get.find<BgmController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final haniHomeData = Get.find<HaniHomeDataController>();
  final userHaniData = Get.find<UserHaniDataController>();
  final userData = Get.find<UserDataController>();

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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.9 : double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFFFDDE2),
            ),
            child: Row(
              children: [
                Spacer(),
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
                          // 윗줄 컨텐츠 3개
                          Row(
                            children: [
                              HaniContents(
                                path: '${haniData['han']}',
                                onTap: () {
                                  haniSongListService(id, widget.keyCode, year);
                                },
                              ),
                              HaniContents(
                                path: '${haniData['workbook']}',
                                onTap: () {
                                  haniMakeCardService(id, widget.keyCode, year);
                                },
                              ),
                              HaniContents(
                                path: '${haniData['quiz']}',
                                onTap: () {
                                  haniQuizService(id, widget.keyCode, year);
                                },
                              ),
                              HaniContents(
                                path: '${haniData['bell']}',
                                onTap: () {
                                  haniGoldenbellSuService(id, widget.keyCode, year);
                                },
                              ),
                            ],
                          ),
                          // 아랫줄 컨텐츠 2개
                          Row(
                            children: [
                              HaniContents(
                                path: '${haniData['story1']}',
                                onTap: () {
                                  Logger().d('1');
                                },
                              ),
                              HaniContents(
                                path: '${haniData['story2']}',
                                onTap: () {},
                              ),
                              HaniContents(
                                path: '${haniData['story3']}',
                                onTap: () {},
                              ),
                              HaniContents(
                                path: '${haniData['story4']}',
                                onTap: () {},
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Spacer(),
                      NewKidokButton(
                        type: 'hani',
                        keycode: widget.keyCode,
                      ),
                      NewStarCount(
                        keyCode: widget.keyCode,
                        type: 'hani',
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
