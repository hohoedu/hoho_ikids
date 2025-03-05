import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_ebook_data.dart';
import 'package:hani_booki/screens/home/home_widgets/home_carousel_slider.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bgmController = Get.find<BgmController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 3;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final userDataController = Get.find<UserDataController>();
  final userEbookDataController = Get.find<UserEbookDataController>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentIndex = 0; // 3에서 0으로 변경
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHaniExist = userEbookDataController.userData!.isHani;
    final isBookiExist = userEbookDataController.userData!.isBooki;
    if (isHaniExist == false) {
      _currentIndex = 1;
    }
    final bool isSibling =
        userDataController.userData!.siblingCount == '1' ? false : true;

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: _currentIndex == 1 ? bookiColor : haniColor,
      appBar: MainAppBar(
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
          width: Platform.isIOS
              ? MediaQuery.of(context).size.width * 0.9
              : double.infinity,
          decoration: BoxDecoration(
            color: _currentIndex == 1 ? bookiColor : haniColor,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: isHaniExist,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                          carouselController.jumpToPage(0);
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
                                    width: _currentIndex == 0
                                        ? constraints.maxWidth
                                        : 0,
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
                        onTap: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                          carouselController.jumpToPage(0);
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
                                    width: _currentIndex == 1
                                        ? constraints.maxWidth
                                        : 0,
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
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Lottie.asset(
                      _currentIndex == 1
                          ? 'assets/lottie/booki.json'
                          : 'assets/lottie/hani.json',
                      fit: BoxFit.contain),
                ),
              ),
              Expanded(
                flex: 5,
                child: HomeCarouselSlider(
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
