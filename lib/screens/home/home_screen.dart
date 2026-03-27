import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_ebook_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/notice/notice_list_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/home/home_widgets/home_carousel_slider.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:hani_booki/services/notice/notice_list_service.dart';
import 'package:hani_booki/services/record/report_read_service.dart';
import 'package:hani_booki/utils/badge_controller.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/version_check.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:hani_booki/widgets/notice/notice_screen.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:badges/badges.dart' as badges;

import '../../_data/auth/user_booki_data.dart';
import '../../utils/get_record_list.dart';
import '../record/record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserHaniDataController haniData = UserHaniDataController();
  UserBookiDataController bookiData = UserBookiDataController();
  final bgmController = Get.find<BgmController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 3;
  final CarouselSliderController carouselController = CarouselSliderController();
  final userDataController = Get.find<UserDataController>();
  final userEbookDataController = Get.find<UserEbookDataController>();
  final BadgeController badgeController = Get.put(BadgeController());
  final GlobalKey logoKey = GlobalKey();
  final GlobalKey carouselKey = GlobalKey();
  String type = '';
  String keyCode = '';

  @override
  void initState() {
    super.initState();

    badgeController.initHive(userDataController.userData!.id);

    noticeListService();
    Get.lazyPut<NoticeListDataController>(() => NoticeListDataController());

    if (Get.isRegistered<UserHaniDataController>()) {
      haniData = Get.find<UserHaniDataController>();
    } else {
      haniData = Get.put(UserHaniDataController());
    }

    if (Get.isRegistered<UserBookiDataController>()) {
      bookiData = Get.find<UserBookiDataController>();
    } else {
      bookiData = Get.put(UserBookiDataController());
    }

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentIndex = 0; // 3에서 0으로 변경
      });
      _checkAndShowDialog();
    });
  }

  Future<void> _checkAndShowDialog() async {
    String currentKeyCode = '';
    String currentType = _currentIndex == 0 ? 'hani' : 'booki';

    if (_currentIndex == 0 && haniData.userHaniDataList.isNotEmpty) {
      currentKeyCode = haniData.userHaniDataList[0].keyCode;
    } else if (_currentIndex == 1 && bookiData.userBookiDataList.isNotEmpty) {
      currentKeyCode = bookiData.userBookiDataList[0].keyCode;
    }

    if (currentKeyCode.isNotEmpty) {
      final result = await reportReadService(currentKeyCode);

      if (result != null && result['read_yn'] != 'Y' && mounted) {
        final hosu = result['hosu'];
        _showRecordDialog(hosu);
      }
    }
  }

  void _showRecordDialog(String hosu) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: screenWidth > 1000
              ? MediaQuery.of(context).size.width * 0.15.w
              : MediaQuery.of(context).size.width * 0.25.w,
          height: screenWidth > 1000
              ? MediaQuery.of(context).size.height * 0.5.h
              : MediaQuery.of(context).size.height * 0.75.h,
          padding: EdgeInsets.all(8),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 40.h),
                      Center(
                        child: Text(
                          '학습기록이 도착했어요!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${userDataController.userData!.username} 친구의 ${_currentIndex == 0 ? '하니' : '부키'} $hosu호\n우리반 '
                    '언어활동을 확인해보세요!',
                    style: TextStyle(fontSize: 8.sp),
                    textAlign: TextAlign.center,
                  ),
                  Column(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            String currentType = _currentIndex == 0 ? 'hani' : 'booki';

                            if (_currentIndex == 0 && haniData.userHaniDataList.isNotEmpty) {
                              keyCode = haniData.userHaniDataList[0].keyCode;
                            } else if (_currentIndex == 1 && bookiData.userBookiDataList.isNotEmpty) {
                              keyCode = bookiData.userBookiDataList[0].keyCode;
                            }

                            if (keyCode.isEmpty) {
                              return;
                            }
                            await getRecordList(keyCode, currentType);
                            await contentStarService(keyCode, currentType);
                            Get.to(() => RecordScreen(
                                  keyCode: keyCode,
                                  type: currentType,
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF252525),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                          ),
                          child: Text('보러가기',
                              style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFF888888),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHaniExist = userEbookDataController.userData!.isHani;
    final isBookiExist = userEbookDataController.userData!.isBooki;

    if (isHaniExist == false) {
      _currentIndex = 1;
    }

    final bool isSibling = userDataController.userData!.siblingCount == '1' ? false : true;

    if (_currentIndex == 0 && haniData.userHaniDataList.isNotEmpty) {
      keyCode = haniData.userHaniDataList[0].keyCode;
      type = 'hani';
    } else if (_currentIndex == 1 && bookiData.userBookiDataList.isNotEmpty) {
      keyCode = bookiData.userBookiDataList[0].keyCode;
      type = 'booki';
    }

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: _currentIndex == 1 ? bookiColor : haniColor,
      appBar: MainAppBar(
        isMain: true,
        isVisibleLeading: false,
        isContent: false,
        onTap: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: MainDrawer(
        isHome: true,
        type: _currentIndex == 0 ? 'hani' : 'booki',
        isSibling: isSibling,
      ),
      body: Center(
        child: Container(
          width: Platform.isIOS && screenWidth <= 1000 ? MediaQuery.of(context).size.width * 0.9 : double.infinity,
          decoration: BoxDecoration(
            color: _currentIndex == 1 ? bookiColor : haniColor,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(
                          flex: 1,
                        ),
                        Visibility(
                          visible: isHaniExist,
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                _currentIndex = 0;
                              });
                              carouselController.jumpToPage(0);
                              await _checkAndShowDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        width: _currentIndex == 0 ? constraints.maxWidth : 0,
                                        decoration: BoxDecoration(
                                          color: mBackWhite,
                                          borderRadius: BorderRadius.horizontal(
                                            right: Radius.circular(50),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: SizedBox(
                                          height: constraints.maxWidth * 0.3,
                                        ),
                                      ),
                                      Center(
                                        key: logoKey,
                                        child: Container(
                                          color: Colors.transparent,
                                          child: SizedBox(
                                            height: constraints.maxWidth * 0.15,
                                            child: Image.asset(
                                              _currentIndex == 0
                                                  ? 'assets/images/hani/hani_logo_co.png'
                                                  : 'assets/images/hani/hani_logo_co.png',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isBookiExist,
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                _currentIndex = 1;
                              });
                              carouselController.jumpToPage(0);
                              await _checkAndShowDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        width: _currentIndex == 1 ? constraints.maxWidth : 0,
                                        decoration: BoxDecoration(
                                          color: mBackWhite,
                                          borderRadius: BorderRadius.horizontal(
                                            right: Radius.circular(50),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: SizedBox(
                                          height: constraints.maxWidth * 0.3,
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          height: constraints.maxWidth * 0.15,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            _currentIndex == 1
                                                ? 'assets/images/booki/booki_logo_co.png'
                                                : 'assets/images/booki/booki_logo_co.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            // onTap: () {
                            // _showRecordDialog("08");
                            // },
                            onTap: () async {
                              if (keyCode.isEmpty) {
                                oneButtonDialog(
                                  title: '학습기록',
                                  content: '확인 가능한 학습기록이 없습니다.',
                                  onTap: () {
                                    Get.back();
                                  },
                                  buttonText: '확인',
                                );
                              }
                              await getRecordList(keyCode, _currentIndex == 0 ? 'hani' : 'booki');
                              await contentStarService(keyCode, _currentIndex == 0 ? 'hani' : 'booki');
                              Get.to(() => RecordScreen(
                                    keyCode: keyCode,
                                    type: _currentIndex == 0 ? 'hani' : 'booki',
                                  ));
                            },
                            child: Center(
                              child: SizedBox(
                                  height: screenHeight * 0.25,
                                  child: Image.asset(_currentIndex == 1
                                      ? 'assets/images/icons/main_report2.png'
                                      : 'assets/images/icons/main_report1.png')),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Lottie.asset(_currentIndex == 1 ? 'assets/lottie/booki.json' : 'assets/lottie/hani.json',
                      fit: BoxFit.contain),
                ),
              ),
              Expanded(
                flex: 5,
                child: HomeCarouselSlider(
                  key: carouselKey,
                  currentIndex: _currentIndex,
                  carouselController: carouselController,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
