import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:logger/logger.dart';

Future<void> getToken(id) async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final token = await firebaseMessaging.getToken();

  sendToken(token, id);
}

// 토큰을 서버로 전송
Future<void> sendToken(token, id) async {
  String url = dotenv.get("FCM_TOKEN_URL");
  final Map<String, dynamic> requestData = {
    'id': id,
    'token': token,
  };

  Logger().d('token = $token');
  try {
    await dio.post(url, data: requestData);
  } catch (e) {
    print('Error: $e');
  }
}
