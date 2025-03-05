import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/_data/kidok/kidok_main_data.dart';
import 'package:hani_booki/_data/kidok/kidok_theme_data.dart';
import 'package:hani_booki/screens/kidok/kidok_home/kidok_home_widgets/kidok_main_card.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_screen.dart';
import 'package:hani_booki/services/kidok/kidok_bookcase_service.dart';
import 'package:hani_booki/services/kidok/kidok_chart_service.dart';
import 'package:hani_booki/services/kidok/kidok_sublist_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:logger/logger.dart';

class KidokHomeScreen extends StatefulWidget {
  final String keyCode;
  final bool isSibling;

  const KidokHomeScreen({
    super.key,
    required this.keyCode,
    required this.isSibling,
  });

  @override
  State<KidokHomeScreen> createState() => _KidokHomeScreenState();
}

class _KidokHomeScreenState extends State<KidokHomeScreen> {
  final bgmController = Get.find<BgmController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final kidokMainController = Get.find<KidokMainDataController>();
  final kidokThemeController = Get.find<KidokThemeDataController>();
  final kidokBookcaseController = Get.find<KidokBookcaseDataController>();
  String type = '';

  void getType(String keyCode) {
    String firstChar = keyCode.substring(0, 1);
    if (firstChar == 'S' || firstChar == 'Y' || firstChar == 'G') {
      type = 'hani';
    } else {
      type = 'booki';
    }
  }

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('kidok');
    getType(widget.keyCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Color(kidokThemeController.kidokThemeData!.kidokColor),
      appBar: MainAppBar(
        isContent: false,
        onTap: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: MainDrawer(
        isHome: false,
        type: type,
        keyCode: widget.keyCode,
        isSibling: widget.isSibling,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/kido_logo.png',
                          fit: BoxFit.contain,
                          scale: 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: type == 'hani'
                              ? MediaQuery.of(context).size.height * 0.12
                              : MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            color: Color(kidokThemeController
                                .kidokThemeData!.subjectColor),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              kidokThemeController.kidokThemeData!.subject,
                              style: TextStyle(
                                  fontSize: 8.sp,
                                  color: fontWhite,
                                  fontFamily: 'BMJUA',
                                  fontWeight: FontWeight.bold),
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth * 0.2;
                      final cardLength =
                          kidokMainController.kidokMainDataList.length;
                      return Stack(
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            right: cardLength == 2
                                ? cardWidth * 1.5 + cardWidth
                                : cardLength == 3
                                    ? cardWidth * 2.5 + cardWidth / 2
                                    : cardWidth * 3.5,
                            left: cardLength == 2
                                ? cardWidth
                                : cardLength == 3
                                    ? cardWidth / 2
                                    : 0,
                            child: Container(
                              width: constraints.maxWidth * 0.3,
                              decoration: BoxDecoration(
                                color: Color(kidokThemeController
                                    .kidokThemeData!.boxColor),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24.0,
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        OutlinedText(
                                          text: '이번 달의',
                                          fillColor: Color(kidokThemeController
                                              .kidokThemeData!.textColor),
                                          outlineColor: fontWhite,
                                          outlineWidth: 2.sp,
                                          fontSize: 13.sp,
                                        ),
                                        OutlinedText(
                                          text: '키독활동',
                                          fillColor: Color(kidokThemeController
                                              .kidokThemeData!.textColor),
                                          outlineColor: fontWhite,
                                          outlineWidth: 2.sp,
                                          fontSize: 13.sp,
                                        ),
                                        OutlinedText(
                                          text: kidokThemeController
                                              .kidokThemeData!.goal,
                                          fillColor: Color(kidokThemeController
                                              .kidokThemeData!.goalTextColor),
                                          outlineColor: fontWhite,
                                          outlineWidth: 2.sp,
                                          fontSize: 5.sp,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () async {
                                              int lastIndex =
                                                  kidokBookcaseController
                                                          .kidokBookcaseDataList
                                                          .length -
                                                      1;
                                              await kidokSublistService(
                                                kidokBookcaseController
                                                    .kidokBookcaseDataList[
                                                        lastIndex]
                                                    .volume,
                                                widget.keyCode,
                                              );
                                              await kidokChartService(
                                                kidokBookcaseController
                                                    .kidokBookcaseDataList[
                                                        lastIndex]
                                                    .volume,
                                                widget.keyCode,
                                              );
                                              Get.to(
                                                () => KidokMainScreen(
                                                  type: type,
                                                  keyCode: widget.keyCode,
                                                  isSibling: widget.isSibling,
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/images/kidok.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Spacer(flex: 1),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            right: cardLength == 2
                                ? cardWidth
                                : cardLength == 3
                                    ? cardWidth / 2
                                    : 0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                children: kidokMainController.kidokMainDataList
                                    .asMap()
                                    .entries
                                    .map((entry) => SizedBox(
                                          width: constraints.maxWidth * 0.2,
                                          height: constraints.maxHeight * 0.8,
                                          child: KidokMainCard(
                                            index: entry.key,
                                            keycode: widget.keyCode,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
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
}
