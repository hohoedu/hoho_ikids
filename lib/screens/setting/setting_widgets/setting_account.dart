import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';

class SettingAccount extends StatelessWidget {
  final UserDataController userData;
  const SettingAccount({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ListTile(
              leading: Text(
                '계정ID',
                style: TextStyle(color: fontSub, fontSize: 12.sp),
              ),
              title: Text(
                userData.userData!.id,
                style: TextStyle(
                  color: fontMain,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              leading: Text(
                '학생 이름',
                style: TextStyle(color: fontSub, fontSize: 12.sp),
              ),
              title: Text(
                userData.userData!.username,
                style: TextStyle(
                  color: fontMain,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
