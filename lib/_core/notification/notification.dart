import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/badge_controller.dart';
import 'package:hani_booki/utils/notification_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

final FlutterLocalNotificationsPlugin notiPlugin = FlutterLocalNotificationsPlugin();

// '신규 E-Book' : 0,
// '언어분석 리포트':1,
// '공지사항':2

Future<void> showNotification(RemoteMessage message) async {
  final badgeController = Get.put(BadgeController());
  final box = Hive.box('notification_settings');

  String? title = message.notification?.title ?? message.data['title'];
  String? body = message.notification?.body ?? message.data['body'];
  String index = message.data['index'];

  Logger().d('index = $index');
  badgeController.saveNotificationStatus(index, false);

  // final bool allChecked = box.get('allChecked', defaultValue: true) as bool;
  // if (!allChecked) {
  //   Logger().d("전체 알림 OFF 상태이므로 스킵");
  //   return;
  // }

  final List<String> keys = [
    '신규 E-BOOK',
    '언어분석 리포트',
    '공지사항',
  ];

  final String idxStr = message.data['index'] ?? '-1';
  final int idx = int.tryParse(idxStr) ?? -1;
  if (idx < 0 || idx >= keys.length) {
    Logger().w("⚠️ 잘못된 index: $idxStr");
    return;
  }
  final String categoryKey = keys[idx];

  // 3) 카테고리 개별 설정 체크
  final bool enabled = box.get('category_$categoryKey', defaultValue: true) as bool;
  if (!enabled) {
    Logger().d("🚫 [$categoryKey] OFF");
    return;
  }
  Logger().d('$categoryKey 와 $index');

  notiPlugin.show(
    0,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        "high_importance_channel",
        "hugh_importance_notification",
        importance: Importance.max,
        priority: Priority.max,
        channelDescription: "channelDescription",
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentBanner: true,
      ),
    ),
  );
}
