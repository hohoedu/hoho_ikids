import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';

void logout() async {
  final storage = Get.find<FlutterSecureStorage>();
  String? userId = await storage.read(key: 'user_id');
  String? userPwd = await storage.read(key: 'user_pwd');
  // 기기에 저장된 유저정보가 있는 경우 삭제
  if (userId != null) {
    await storage.delete(key: 'user_id');
  }
  if (userPwd != null) {
    await storage.delete(key: 'user_pwd');
  }

  Get.offAll(() => const LoginScreen());
}
