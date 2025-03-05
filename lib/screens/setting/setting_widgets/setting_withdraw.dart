import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/widgets/dialog.dart';

class SettingWithdraw extends StatelessWidget {
  const SettingWithdraw({
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
              showWithdrawDialog();
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
                    '회원 탈퇴',
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
