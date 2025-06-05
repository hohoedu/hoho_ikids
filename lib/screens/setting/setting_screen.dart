import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
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
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  final userData = Get.find<UserDataController>();

  SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String appVersion = '';
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().pauseBgm();
    verifyVersion();
  }

  Future<void> verifyVersion() async {
    String appleId = '6741888275';
    String playStoreId = 'com.hohoedu.hani_booki';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });

    final result = await AppVersionUpdate.checkForUpdates(
      appleId: appleId,
      playStoreId: playStoreId,
      country: 'kr',
    );
    setState(() {
      isUpdate = result.canUpdate ?? false;
    });
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
                flex: 11,
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
              Spacer(),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    oneButtonDialog(
                        title: '설정',
                        content: '저장 되었습니다.',
                        onTap: () {
                          Get.back();
                        },
                        buttonText: '확인');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.2,
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
              ),
              Spacer(),
              Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      isUpdate ? Text('버전 정보: v$appVersion -업데이트가 필요합니다.') : Text('버전정보: v$appVersion'
                                          ' '),
                                ),
                              ),
                            ),
                          ),
                          isUpdate
                              ? Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      String url = '';

                                      if (Platform.isAndroid) {
                                        url = 'https://play.google.com/store/apps/details?id=com.hohoedu.hani_booki';
                                      } else if (Platform.isIOS) {
                                        url = 'https://apps.apple.com/app/id6741888275';
                                      }

                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                      } else {
                                        Get.snackbar('오류', '스토어로 이동할 수 없습니다.');
                                      }
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black, borderRadius: BorderRadius.circular(15)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              '업데이트',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      )),
                ),
              ),
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
