import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class NotificationController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initBroadcastSubscription();
  }

  Future<void> _initBroadcastSubscription() async {
    final box = Hive.box('notification_settings');
    final enabled = box.get('category_교육정보', defaultValue: true) as bool;
    await _setBroadcast(enabled);
  }

  Future<void> _setBroadcast(bool enable) async {
    if (enable) {
      await FirebaseMessaging.instance.subscribeToTopic('broadcast');
      Logger().d("✅ 'broadcast' 토픽 구독 완료");
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('broadcast');
      Logger().d("✅ 'broadcast' 토픽 구독 취소");
    }
  }

  void toggleBroadcast(bool enable) {
    _setBroadcast(enable);
  }

  @override
  void onClose() {
    FirebaseMessaging.instance.unsubscribeFromTopic('broadcast');
    Logger().d("✅ 'broadcast' 토픽 구독 취소");
    super.onClose();
  }
}
