import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notiPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  Map<String, dynamic> data = message.data;
  await cancelNotification();
  await requestPermissions();
  await showNotification(data);
}

Future<void> cancelNotification() async {
  await notiPlugin.cancelAll();
}

Future<void> showNotification(Map<String, dynamic> message) async {
  notiPlugin.show(
    11,
    message['title'],
    message['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        importance: Importance.max,
        priority: Priority.max,
        channelDescription: "channelDescription",
        icon: '@mionao/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentBanner: true,
      ),
    ),
  );
}

Future<void> requestPermissions() async {
  await notiPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}
