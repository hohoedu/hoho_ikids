// fcm 알림 세팅

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hani_booki/_core/notification/background_handler.dart';
import 'package:hani_booki/firebase_options.dart';
import 'package:logger/logger.dart';

Future<void> setupFcm() async {
  // FCM 초기화
  await Firebase.initializeApp(
    name: 'hanibooki',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // iOS: 포그라운드 메시지 프레젠테이션 옵션 업데이트
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Android: 채널
  const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'high_importance_notification',
    importance: Importance.max,
  );

  // Android: 알림 채널 생성, 초기화(Android에서는 알림을 표시하기 전에 채널을 설정)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestCriticalPermission: true,
      )));

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
}
