import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_once_verification_screen.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_twice_verification_screen.dart';
import 'package:hani_booki/services/auth/withdraw_service.dart';
import 'package:hani_booki/services/notice/notice_list_service.dart';
import 'package:hani_booki/widgets/notice/notice_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

void oneButtonDialog({
  bool isBarrier = false,
  required String title,
  required String content,
  required VoidCallback onTap,
  required String buttonText,
}) {
  Get.defaultDialog(
    barrierDismissible: isBarrier,
    backgroundColor: Colors.white,
    title: title,
    middleText: content,
    buttonColor: Colors.green,
    textConfirm: buttonText,
    onConfirm: onTap,
  );
}

void twoButtonDialog({
  required bool isBarrier,
  required String title,
  required String content,
  required VoidCallback confirmOnTap,
  required VoidCallback cancelOnTap,
  required String confirmButtonText,
  required String cancelButtonText,
}) {
  Get.defaultDialog(
    barrierDismissible: isBarrier,
    backgroundColor: Colors.white,
    title: title,
    middleText: content,
    buttonColor: Colors.green,
    textConfirm: confirmButtonText,
    onConfirm: confirmOnTap,
    textCancel: cancelButtonText,
    onCancel: cancelOnTap,
  );
}

void showGameCompleteDialog({
  required String title,
  required String content,
  required VoidCallback confirm,
  required String confirmText,
  required VoidCallback cancel,
  required String cancelText,
}) {
  Get.defaultDialog(
    barrierDismissible: false,
    backgroundColor: Colors.white,
    title: title,
    middleText: content,
    buttonColor: Colors.green,
    textConfirm: confirmText,
    onConfirm: confirm,
    textCancel: cancelText,
    onCancel: cancel,
  );
}

// void showBackDialog(isPortraitMode) {
//   Get.defaultDialog(
//       backgroundColor: mBackWhite,
//       title: '안내',
//       middleText: '학습을 취소하고 나가시겠습니까?\n'
//           '진행중인 콘텐츠가 저장되지 않습니다.',
//       onConfirm: () async {
//         if (isPortraitMode == true) {
//           if (Platform.isIOS) {
//             await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
//           } else {
//             await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
//           }
//         }
//         Get.back();
//         Get.back();
//       },
//       textConfirm: '확인',
//       onCancel: () {},
//       textCancel: '취소',
//       buttonColor: Colors.green);
// }

void showBackDialog(isPortraitMode) {
  Get.generalDialog(
    // barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Lottie.asset(
                    'assets/lottie/back.json',
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '별 포인트를 받기 전에 나가면 저장이 되지 않아요!\n정말로 나가시겠어요?',
                          style: TextStyle(
                            color: fontWhite,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.17,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '나가기',
                                style: TextStyle(color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.17,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '계속 하기',
                                style: TextStyle(color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

void showKidokBackDialog(isPortraitMode) {
  Get.generalDialog(
    // barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Lottie.asset(
                    'assets/lottie/back.json',
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '지금 나가면 문제들은 저장이 되지 않아요!\n정말로 나가시겠어요?',
                          style: TextStyle(
                            color: fontWhite,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.17,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '나가기',
                                style: TextStyle(color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.17,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '계속 하기',
                                style: TextStyle(color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

void verticalBackDialog(isPortraitMode) {
  Get.generalDialog(
    // barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Lottie.asset('assets/lottie/back.json', height: MediaQuery.of(context).size.height * 0.5),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '별 포인트를 받기 전에 \n나가면 저장이 되지 않아요!\n정말로 나가시겠어요?',
                            style: TextStyle(
                              color: fontWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            if (Platform.isIOS) {
                              await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
                            } else {
                              await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                            }

                            Get.back();
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '나가기',
                                style: TextStyle(color: fontMain, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '계속 하기',
                                style: TextStyle(color: fontMain, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

void showCodeErrorDialog({
  required String title,
  required String content,
  required VoidCallback confirm,
  required String confirmText,
}) {
  Get.defaultDialog(
    barrierDismissible: false,
    backgroundColor: mBackWhite,
    title: title,
    middleText: content,
    buttonColor: Colors.green,
    textConfirm: confirmText,
    onConfirm: confirm,
  );
}

void lottieDialog({required VoidCallback onMain, required VoidCallback onReset}) {
  Get.generalDialog(
    // barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black26,
    // 다이얼로그 배경 어둡게 처리
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent, // 원하는 배경색
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 7,
                  child:
                      Lottie.asset('assets/lottie/star_point.json', height: MediaQuery.of(context).size.height * 0.5),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '+1 스타 ',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '획득!',
                            style: TextStyle(
                              color: fontWhite,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: onReset,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.17,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '다시하기',
                                style: TextStyle(color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: onMain,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.17,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '메인으로',
                                style: TextStyle(color: fontMain, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

void verticalLottieDialog({required VoidCallback onMain, required VoidCallback onReset}) {
  Get.generalDialog(
    // barrierDismissible: true,
    barrierLabel: 'Dialog',
    barrierColor: Colors.black26,
    // 다이얼로그 배경 어둡게 처리
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child:
                      Lottie.asset('assets/lottie/star_point.json', height: MediaQuery.of(context).size.height * 0.5),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '+1 스타 ',
                            style: TextStyle(
                              color: Colors.yellow,
                            ),
                          ),
                          TextSpan(
                            text: '획득!',
                            style: TextStyle(
                              color: fontWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: onReset,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '다시하기',
                                style: TextStyle(color: fontMain, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: onMain,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '메인으로',
                                style: TextStyle(color: fontMain, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

void versionDialog(String platform, String storeUrl) {
  Get.defaultDialog(
    backgroundColor: mBackWhite,
    title: '버전 불일치',
    middleText: '최신 버전이 아니면 원활한 진행이 어렵습니다.',
    textConfirm: '확인',
    buttonColor: Colors.green,
    textCancel: '취소',
    barrierDismissible: false,
    onConfirm: () async {
      // 앱 스토어 URL 설정
      String url = '';
      if (platform == "AOS") {
        url = 'https://play.google.com/store/apps/details?id=com.hohoedu.hani_booki';
      } else if (platform == "IOS") {
        url = 'https://apps.apple.com/app/id6741888275';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('오류', '스토어로 이동할 수 없습니다.');
      }
      SystemNavigator.pop();
    },
    onCancel: () {
      SystemNavigator.pop();
    },
  );
}

void showWithdrawDialog() {
  Get.dialog(
    Dialog(
      backgroundColor: mBackWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 0.75,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '회원탈퇴',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '가입된 회원정보 및 학습이력 데이터가 모두 삭제되며\n'
                  '탈퇴 후에는 계정을 복구하실 수 없습니다.\n'
                  '회원 탈퇴를 진행하시겠습니까?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('취소', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await withdrawService();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('탈퇴', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}

void showCodeDeleteDialog({required VoidCallback onDeleteConfirmed}) {
  Get.dialog(
    Dialog(
      backgroundColor: mBackWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 0.75,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '가입코드 삭제',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: '가입코드 삭제시 연결된 E-BOOK 정보가 모두 삭제되며\n데이터 복구가 불가능합니다.\n',
                      ),
                      TextSpan(
                        text: '반드시 잘못 입력하셨을 경우에만 삭제',
                        style: TextStyle(color: Colors.red),
                      ),
                      const TextSpan(
                        text: '를 부탁드립니다.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('취소', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        onDeleteConfirmed();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text('삭제에 동의합니다.', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}

void showTermsDialog(BuildContext context,
    {required String title,
    required String assetTextPath,
    required VoidCallback onConfirmed,
    bool useZeroButtonPadding = false}) {
  Future<String> loadText() async {
    return await rootBundle.loadString(assetTextPath);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(title),
        ),
        buttonPadding: useZeroButtonPadding ? EdgeInsets.zero : null,
        content: FutureBuilder<String>(
          future: loadText(),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: ListBody(
                children: [Text(snapshot.data ?? 'No terms found')],
              ),
            );
          },
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Get.back();
                onConfirmed();
              },
              child: Text(
                '확인',
                style: TextStyle(color: fontWhite),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
            ),
          ),
        ],
      );
    },
  ).then((_) {
    // 다이얼로그 종료 후에도 한번 실행할 경우 사용
    onConfirmed();
  });
}

void showNameCheckDialog({
  required bool isBarrier,
  required String title,
  required Widget content,
  required VoidCallback confirmOnTap,
  required VoidCallback cancelOnTap,
  required String confirmButtonText,
  required String cancelButtonText,
}) {
  Get.defaultDialog(
    barrierDismissible: isBarrier,
    backgroundColor: Colors.white,
    title: title,
    content: content,
    buttonColor: Colors.green,
    textConfirm: confirmButtonText,
    onConfirm: confirmOnTap,
    textCancel: cancelButtonText,
    onCancel: cancelOnTap,
  );
}

void showNoticeDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: NoticeScreen(),
          ),
        ),
      );
    },
  );
}

void showParentGateDialog(BuildContext context, String url) {
  final rand = Random();
  final num1 = rand.nextInt(99) + 1;
  final num2 = rand.nextInt(99) + 1;
  final isAddition = rand.nextBool();
  final operator = isAddition ? '+' : '-';
  final correctAnswer = isAddition ? num1 + num2 : num1 - num2;

  String input = '';
  String? errorText;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: 500,
          height: 250,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: [
                  // 왼쪽: 문제 및 입력 상태
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("부모님 확인", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text("문제: $num1 $operator $num2 = ?", style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            input.isEmpty ? "정답 입력" : input,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              errorText!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text("취소"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const VerticalDivider(),

                  // 오른쪽: 키패드
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 220,
                      child: _buildKeypad(onTap: (value) async {
                        setState(() {
                          if (value == '←') {
                            if (input.isNotEmpty) input = input.substring(0, input.length - 1);
                          } else if (value == '확인') {
                            final answer = int.tryParse(input);
                            if (answer == correctAnswer) {
                              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              Navigator.of(ctx).pop();
                            } else {
                              errorText = "정답이 아닙니다.";
                            }
                          } else {
                            if (input.length < 3) input += value;
                          }
                        });
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _buildKeypad({required void Function(String value) onTap}) {
  final keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['←', '0', '확인'],
  ];

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: keys
        .map(
          (row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row
                .map(
                  (key) => Padding(
                    padding: const EdgeInsets.all(4),
                    child: ElevatedButton(
                      onPressed: () => onTap(key),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(50, 45),
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(key, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
  );
}
