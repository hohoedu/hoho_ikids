import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_theme_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/kidok/kidok_main_service.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:logger/logger.dart';

class NewKidokButton extends StatelessWidget {
  final String keycode;
  final String type;

  final kidokThemeController = Get.find<KidokThemeDataController>();
  final userData = Get.find<UserDataController>();

  NewKidokButton({super.key, required this.keycode, required this.type});

  @override
  Widget build(BuildContext context) {
    final bool isSibling = userData.userData!.siblingCount == '1' ? false : true;
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            await kidokMainService(
              userData.userData!.year,
              keycode,
              isSibling,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              width: double.infinity,
              height: 185.h,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: screenWidth >= 1000
                        ? EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
                        : EdgeInsets.symmetric(vertical: 16.0),
                    child: Align(
                      alignment: const Alignment(0.0, 0.5),
                      child: ClipPath(
                        clipper: KidokClipper(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(kidokThemeController.kidokThemeData!.boxColor),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: type == 'hani' ? EdgeInsets.zero : EdgeInsets.only(bottom: 8.0),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: fontMain,
                                        fontFamily: 'Cookie',
                                        fontSize: 20,
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                            text: type == 'hani'
                                                ? '${kidokThemeController.kidokThemeData!.subject}'
                                                // ? '끈기'
                                                : '지식\n확장',
                                            style: TextStyle(color: Colors.black, height: 1.2)),
                                        TextSpan(
                                          text: '\n독서활동',
                                          style: TextStyle(
                                              color: Color(kidokThemeController.kidokThemeData!.subjectColor),
                                              // color: Colors.red,
                                              fontSize: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..scale(-1.0, 1.0),
                          child: Image.asset(
                            'assets/images/kido.png',
                            scale: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/kido_logo_vertical.png',
                      scale: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class KidokClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h / 10)
      ..quadraticBezierTo(w / 4, 0, w * 4 / 4, h / 15)
      // ..quadraticBezierTo(w * (6 / 7), h / 20, w, h / 10)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
