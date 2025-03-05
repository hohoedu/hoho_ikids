import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/services/auth/login_service.dart';

class AutoLogin extends StatelessWidget {
  const AutoLogin({super.key});

  Future<Widget> _checkAutoLogin() async {
    final storage = Get.find<FlutterSecureStorage>();
    final storedId = await storage.read(key: 'user_id');
    final storedPwd = await storage.read(key: 'user_pwd');
    if (storedId != null && storedPwd != null) {
      await loginService(storedId, storedPwd, true);

      return Container();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkAutoLogin(),
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
          // 에러 발생 시 로그인 화면으로 이동
          return const LoginScreen();
        }
        return snapshot.data!;
      },
    );
  }
}
