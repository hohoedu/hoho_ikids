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
  final BoxConstraints constraints;

  final kidokThemeController = Get.find<KidokThemeDataController>();
  final userData = Get.find<UserDataController>();

  NewKidokButton({super.key, required this.keycode, required this.type, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final bool isSibling = userData.userData!.siblingCount == '1' ? false : true;
    return GestureDetector(
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
          decoration: BoxDecoration(color: Colors.transparent),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Align(
                  alignment: const Alignment(0.0, 0.5),
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth >= 1000 ? constraints.maxWidth * 0.75 : constraints.maxWidth * 0.83,
                        height: screenWidth >= 1000 ? constraints.maxHeight * 0.35 : constraints.maxHeight * 0.35,
                        decoration: BoxDecoration(
                          color: Color(kidokThemeController.kidokThemeData!.boxColor),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset('assets/images/kido_logo_vertical.png'),
                            ),
                            Align(
                              alignment: screenWidth >= 1000 ? Alignment.center : Alignment.bottomCenter,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: fontMain,
                                    fontFamily: 'Cookie',
                                    fontSize: screenWidth >= 1000 ? 30 : 20,
                                    height: 1.2,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          type == 'hani' ? '${kidokThemeController.kidokThemeData!.subject}' : '지식\n확장',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}

// class KidokClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;
//     Path path = Path()
//       ..moveTo(0, 0)
//       ..lineTo(0, h / 10)
//       ..quadraticBezierTo(w / 4, 0, w * 4 / 4, h / 15)
//       // ..quadraticBezierTo(w * (6 / 7), h / 20, w, h / 10)
//       ..lineTo(w, h)
//       ..lineTo(0, h)
//       ..close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }
