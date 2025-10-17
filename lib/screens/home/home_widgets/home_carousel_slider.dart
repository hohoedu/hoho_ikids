import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_booki_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_ebook_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/booki/booki_home/booki_home_screen.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_screen.dart';
import 'package:hani_booki/services/booki/booki_content_service.dart';
import 'package:hani_booki/services/hani/hani_content_service.dart';
import 'package:hani_booki/services/kidok/kidok_theme_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/connectivityController.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class HomeCarouselSlider extends StatefulWidget {
  final int currentIndex;
  final CarouselSliderController carouselController;

  const HomeCarouselSlider({
    super.key,
    required this.carouselController,
    required this.currentIndex,
  });

  @override
  State<HomeCarouselSlider> createState() => _HomeCarouselSliderState();
}

class _HomeCarouselSliderState extends State<HomeCarouselSlider> {
  final bgmController = Get.find<BgmController>();
  final userDataController = Get.find<UserDataController>();
  final userEbookDataController = Get.find<UserEbookDataController>();

  UserHaniDataController haniController = UserHaniDataController();
  UserBookiDataController bookiController = UserBookiDataController();

  @override
  void initState() {
    super.initState();
    getUserEbookData();
  }

  void getUserEbookData() {
    if (userEbookDataController.userData!.isHani) {
      haniController = Get.find<UserHaniDataController>();
    }
    if (userEbookDataController.userData!.isBooki) {
      bookiController = Get.find<UserBookiDataController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> userDataList =
        widget.currentIndex == 1 ? bookiController.userBookiDataList : haniController.userHaniDataList;
    final visibleDataList = userDataList.where((data) => int.parse(data.date) >= -10).toList();
    return userDataList.isNotEmpty
        ? CarouselSlider(
            items: visibleDataList.map(
              (data) {
                return Builder(
                  builder: (context) {
                    final bool isVisible = int.parse(data.date) >= 0;
                    return GestureDetector(
                      onTap: isVisible
                          ? () async {
                              widget.currentIndex == 1
                                  ? await kidokThemeService(data.keyCode, userDataController.userData!.year)
                                  : await kidokThemeService(data.keyCode, userDataController.userData!.year);
                              widget.currentIndex == 1
                                  ? await bookiContentService(data.keyCode, userDataController.userData!.schoolId,
                                      userDataController.userData!.year)
                                  : await haniContentService(data.keyCode, userDataController.userData!.schoolId,
                                      userDataController.userData!.year);
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: screenWidth>=1000 && Platform.isIOS ? screenHeight * 0.5 : screenHeight * 0.6,
                              decoration: BoxDecoration(
                                color: mBackWhite,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      userDataController.userData!.userType == "C"
                                          ? userDataList.indexOf(data) == 0
                                              ? '이번 달의 학습'
                                              : '지난 달의 학습'
                                          : '진행 중인 학습',
                                      style: TextStyle(
                                          color: fontMain,
                                          fontSize: 8.5.sp,
                                          // fontSize: 20,
                                          fontFamily: 'GSans-Bold',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                              width: 2, color: widget.currentIndex == 1 ? bookiColor : haniColor),
                                        ),
                                        child: Text(
                                          (int.parse(data.date) >= 0) ? '${data.date}일 남음' : '0일 남음',
                                          style: TextStyle(
                                            color: widget.currentIndex == 1 ? bookiColor : haniColor,
                                            fontSize: 6.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Image.network(data.imagePath),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isVisible)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ).toList(),
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                autoPlay: false,
                scrollDirection: Axis.vertical,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                viewportFraction: 0.65),
            carouselController: widget.carouselController,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Image.asset('assets/images/before_class.png'));
  }
}
