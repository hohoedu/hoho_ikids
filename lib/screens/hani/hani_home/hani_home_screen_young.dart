import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/screens/hani/drag_puzzle/drag_puzzle_screen.dart';
import 'package:hani_booki/screens/hani/make_card/make_card_screen.dart';
import 'package:hani_booki/screens/hani/quiz/quiz_screen.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/kidok_button.dart';
import 'package:hani_booki/widgets/new_kidok_button.dart';
import 'package:hani_booki/widgets/new_star_count.dart';
import 'package:hani_booki/widgets/star_count.dart';

class HaniHomeScreenYoung extends StatefulWidget {
  final String keyCode;

  const HaniHomeScreenYoung({super.key, required this.keyCode});

  @override
  State<HaniHomeScreenYoung> createState() => _HaniHomeScreenYoungState();
}

class _HaniHomeScreenYoungState extends State<HaniHomeScreenYoung> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final userHaniData = Get.find<UserHaniDataController>();
  final userData = Get.find<UserDataController>();

  @override
  Widget build(BuildContext context) {
    String id = userData.userData!.id;
    String year = userData.userData!.year;
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
        isSibling: userData.userData!.siblingCount == '1' ? false : true,
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
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 윗줄 컨텐츠 3개
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => MakeCardScreen());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => QuizScreen());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => DragPuzzleScreen());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 아랫줄 컨텐츠 2개
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
