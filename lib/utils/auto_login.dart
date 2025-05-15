import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/join_screen.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/services/auth/login_service.dart';
import 'package:hani_booki/utils/version_check.dart';
import 'package:logger/logger.dart';

final Future<void> autoLoginFuture = _checkAutoLogin();

Future<void> _checkAutoLogin() async {
  final storage = Get.find<FlutterSecureStorage>();
  final storedId = await storage.read(key: 'user_id');
  final storedPwd = await storage.read(key: 'user_pwd');
  if (storedId != null && storedPwd != null) {
    await loginService(storedId, storedPwd, true);
  } else {
    Get.offAll(() => const LoginScreen());
  }
}

class AutoLogin extends StatelessWidget {
  const AutoLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: autoLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: mBackAuth,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return const LoginScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
