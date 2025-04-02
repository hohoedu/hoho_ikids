import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/services/auth/ebook_status_service.dart';
import 'package:hani_booki/services/sibling_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:logger/logger.dart';

class SiblingScreen extends StatelessWidget {
  final siblingData = Get.find<SiblingDataController>();
  final userData = Get.find<UserDataController>();

  SiblingScreen({super.key});

  void _userUpdate(index) {
    userData.updateUserData(
      id: siblingData.siblingDataList[index].id,
      username: siblingData.siblingDataList[index].username,
      schoolId: siblingData.siblingDataList[index].schoolId,
      schoolName: siblingData.siblingDataList[index].schoolName,
      year: userData.userData!.year,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mBackAuth,
      appBar: MainAppBar(
        title: ' ',
        isContent: false,
        isVisibleLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                '학습을 진행할 프로필을 선택해 주세요.',
                style: TextStyle(
                  color: fontMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double itemSize = constraints.maxWidth / 5; // 한 줄에 5개까지 배치
                  return Center(
                    child: Wrap(
                      spacing: 10.w, // 요소 간 간격
                      runSpacing: 10.h, // 줄 간 간격
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        siblingData.siblingDataList.length,
                            (index) {
                          final selectedSibling = siblingData.siblingDataList[index];
                          return GestureDetector(
                            onTap: () async {
                              await ebookStatusService(
                                selectedSibling.id,
                                selectedSibling.schoolId,
                                userData.userData!.year,
                              );
                              _userUpdate(index);
                              Get.to(() => const HomeScreen());
                            },
                            child: Container(
                              height: itemSize,
                              width: itemSize,
                              decoration: BoxDecoration(
                                color: profileColor[index % profileColor.length],
                                borderRadius: BorderRadius.circular(30.sp),
                              ),
                              child: Center(
                                child: Text(
                                  selectedSibling.username,
                                  style: TextStyle(
                                    color: fontWhite,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
