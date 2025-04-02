import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/badge_controller.dart';
import 'package:hani_booki/utils/notification_controller.dart';
import 'package:logger/logger.dart';

final FlutterLocalNotificationsPlugin notiPlugin = FlutterLocalNotificationsPlugin();

Future<void> showNotification(RemoteMessage message) async {
  final controller = Get.find<NotificationController>();
  final badgeController = Get.find<BadgeController>();


  String? title = message.notification?.title ?? message.data['title'];
  String? body = message.notification?.body ?? message.data['body'];
  String? category = message.data['category'];
  String index = message.data['index'] ?? 'null';

  if (category != null && !controller.isNotificationEnabled(category)) {
    return;
  }

  badgeController.saveNotificationStatus(index, false);

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
