import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/setting/setting_widgets/seeting_title.dart';
import 'package:hani_booki/screens/setting/setting_widgets/setting_notification.dart';
import 'package:hani_booki/screens/setting/setting_widgets/setting_volume.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

class SettingScreen extends StatefulWidget {
  final userData = Get.find<UserDataController>();

  SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().pauseBgm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: MainAppBar(
        title: ' ',
        isContent: false,
      ),
      body: Center(
        child: Container(
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
          child: Column(
            children: [
              SettingTitle(),
              Expanded(
                flex: 6,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SettingVolume(),
                        SettingNotification(),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  oneButtonDialog(
                      title: '설정',
                      content: '저장 되었습니다.',
                      onTap: () {
                        Get.back();
                      },
                      buttonText: '확인');
                },
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    height: 50.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFE8900),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        '저장하기',
                        style: TextStyle(
                          color: fontWhite,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
