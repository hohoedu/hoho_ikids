import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:logger/logger.dart';

Future<void> getToken(id) async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // iOS는 APNS 토큰이 먼저 발급되어야 FCM 토큰을 받을 수 있는데,
  // 앱 실행 직후에는 APNS 등록이 아직 끝나지 않았을 수 있어 잠깐 대기 후 재시도
  if (Platform.isIOS) {
    final hasApnsToken = await _waitForApnsToken(maxAttempts: 3, delay: const Duration(seconds: 1));
    if (!hasApnsToken) {
      Logger().d('APNS token not ready yet, will retry token registration in background');
      _retryTokenInBackground(id);
      return;
    }
  }

  final token = await firebaseMessaging.getToken();
  Logger().d(token);
  sendToken(token, id);
}

Future<bool> _waitForApnsToken({required int maxAttempts, required Duration delay}) async {
  final firebaseMessaging = FirebaseMessaging.instance;
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    final apnsToken = await firebaseMessaging.getAPNSToken();
    if (apnsToken != null) return true;
    await Future.delayed(delay);
  }
  return await firebaseMessaging.getAPNSToken() != null;
}

// 로그인 흐름을 막지 않기 위해 백그라운드에서 지수적으로 간격을 늘려가며 재시도 (최대 5회, 알림 권한 거부 등으로 영영 발급되지 않는 경우 포기)
void _retryTokenInBackground(id, {int attempt = 1}) {
  if (attempt > 5) {
    Logger().d('APNS token still unavailable after retries, giving up');
    return;
  }
  Future.delayed(Duration(seconds: attempt * 5), () async {
    try {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        _retryTokenInBackground(id, attempt: attempt + 1);
        return;
      }
      final token = await FirebaseMessaging.instance.getToken();
      Logger().d('token (retry #$attempt) = $token');
      sendToken(token, id);
    } catch (e) {
      Logger().d('retry getToken error = $e');
      _retryTokenInBackground(id, attempt: attempt + 1);
    }
  });
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
