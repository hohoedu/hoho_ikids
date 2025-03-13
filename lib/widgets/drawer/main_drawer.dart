import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/alert/alert_screen.dart';
import 'package:hani_booki/screens/home/sibling_screen.dart';
import 'package:hani_booki/screens/record/record_home_shool/record_home_school_screen.dart';
import 'package:hani_booki/screens/record/record_screen.dart';
import 'package:hani_booki/screens/setting/setting_screen.dart';
import 'package:hani_booki/screens/setting/setting_widgets/setting_terms.dart';
import 'package:hani_booki/services/auth/logout.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:hani_booki/utils/get_record_list.dart';
import 'package:hani_booki/utils/get_user_code.dart';
import 'package:hani_booki/widgets/notice/notice_screen.dart';
import 'package:logger/logger.dart';

class MainDrawer extends StatelessWidget {
  final bool isHome;
  final String keyCode;
  final String type;
  final bool isSibling;

  const MainDrawer({
    super.key,
    required this.isHome,
    required this.type,
    required this.isSibling,
    this.keyCode = '',
  });

  @override
  Widget build(BuildContext context) {
    final userData = Get.find<UserDataController>();
    return Drawer(
      backgroundColor: mBackWhite,
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: type == 'hani'
                          ? Image.asset('assets/images/icons/hani.png')
                          : Image.asset('assets/images/icons/booki.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userData.userData!.username} 어린이',
                            style: TextStyle(
                                color: fontMain,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userData.userData!.schoolName,
                            style: TextStyle(color: fontSub),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // GestureDetector(
                //   onTap: () {
                //     Get.back();
                //     Get.to(() => const AlertScreen());
                //   },
                //   child: SizedBox(
                //     width: 25,
                //     height: 25,
                //     child: Image.asset(
                //       'assets/images/icons/bell.png',
                //     ),
                //   ),
                // ),
              ],
            ),
            Divider(),
            // GestureDetector(
            //   onTap: () {
            //     Get.back();
            //     showGeneralDialog(
            //       context: context,
            //       barrierDismissible: false,
            //       pageBuilder: (context, animation, secondaryAnimation) {
            //         return Center(
            //           child: Material(
            //             color: Colors.transparent,
            //             child: Container(
            //               width: MediaQuery.of(context).size.width * 0.85,
            //               height: MediaQuery.of(context).size.height * 0.9,
            //               decoration: BoxDecoration(
            //                 color: Colors.white,
            //                 borderRadius: BorderRadius.circular(25),
            //               ),
            //               child: NoticeScreen(),
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   },
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //     child: Row(
            //       children: [
            //         SizedBox(
            //           width: 20,
            //           height: 20,
            //           child: Image.asset(
            //               'assets/images/icons/learning_record.png'),
            //         ),
            //         const SizedBox(width: 16),
            //         const Expanded(
            //           child: Text('공지사항'),
            //         ),
            //         const Icon(Icons.navigate_next),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 학습 기록
                  Visibility(
                    visible: !isHome,
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await contentStarService(keyCode);
                        await getRecordList(keyCode, type);
                        // Get.to(() => RecordScreen(keyCode: keyCode, type: type));
                        Get.to(() => RecordHomeSchoolScreen(type: type));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset(
                                  'assets/images/icons/learning_record.png'),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('학습 기록')),
                            const Icon(Icons.navigate_next),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 내 정보
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await getUserCode();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                Image.asset('assets/images/icons/my_info.png'),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: Text('내 정보')),
                          const Icon(Icons.navigate_next),
                        ],
                      ),
                    ),
                  ),
                  // 형제 변경
                  Visibility(
                    visible: isSibling,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.offAll(() => SiblingScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset(
                                  'assets/images/icons/change_sibling.png'),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('형제 변경')),
                            const Icon(Icons.navigate_next),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 설정
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => SettingScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                Image.asset('assets/images/icons/setting.png'),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: Text('설정')),
                          const Icon(Icons.navigate_next),
                        ],
                      ),
                    ),
                  ),

                  // 로그아웃
                  GestureDetector(
                    onTap: () {
                      logout();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                Image.asset('assets/images/icons/logout.png'),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: Text('로그아웃')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  SettingTerms(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
