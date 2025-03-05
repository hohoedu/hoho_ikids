import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/services/auth/logout.dart';

class SettingLogout extends StatelessWidget {
  const SettingLogout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              logout();
              Get.offAll(() => const LoginScreen());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: flame,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Center(
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: fontWhite,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Spacer(),
      ],
    );
  }
}
