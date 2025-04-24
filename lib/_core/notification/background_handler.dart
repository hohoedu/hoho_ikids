
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/badge_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화 (필수)
  await Hive.initFlutter();

  // BadgeController 초기화
  final BadgeController badgeController = Get.put(BadgeController());
  // await badgeController.initHive();

  String index = message.data['index'];

  // 알림 데이터 저장하기 (Hive)
  badgeController.saveNotificationStatus(index, false);
}