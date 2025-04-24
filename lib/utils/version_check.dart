import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/utils/auto_login.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late Future<bool> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = verifyVersion();
  }

  Future<bool> verifyVersion() async {
    String appleId = '6741888275';
    String playStoreId = 'com.hohoedu.hani_booki';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final result = await AppVersionUpdate.checkForUpdates(
      appleId: appleId,
      playStoreId: playStoreId,
      country: 'kr',
    );

    Logger().d('appVersion = ${packageInfo.version}');
    Logger().d('storeVersion = ${result.storeVersion}');

    if (result.canUpdate == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        versionDialog(Platform.isAndroid ? 'AOS' : 'IOS', result.storeUrl!);
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _versionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Expanded(child: Center(child: CircularProgressIndicator())),
                Expanded(child: Text('버전을 확인하고 있습니다.'))
              ],
            )),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('버전 확인 중 오류 발생: ${snapshot.error}')),
          );
        } else {
          bool versionOk = snapshot.data ?? false;
          if (versionOk) {
            return const AutoLogin();
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}
