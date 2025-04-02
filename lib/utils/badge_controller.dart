import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BadgeController extends GetxController {
  static const String boxName = 'badgeStatus';
  late Box<Map> _badgeBox;
  var isBadgeVisible = true.obs;

  Future<void> initHive() async {
    _badgeBox = await Hive.openBox<Map>(boxName);
    updateBadgeVisibility();
  }

  void updateBadgeVisibility() {
    // 하나라도 읽지 않은 알림이 있으면 true로 설정
    isBadgeVisible.value = _badgeBox.values.any((value) => value['status'] == false);
  }

  void saveNotificationStatus(String index, bool status) {
    // FCM 알림이 오면 해당 index를 저장
    _badgeBox.put(index.toString(), {'index': index, 'status': status});
    updateBadgeVisibility();
  }

  void markNotificationAsRead(String index) {
    // 알림 읽기 처리
    if (_badgeBox.containsKey(index.toString())) {
      _badgeBox.put(index.toString(), {'index': index, 'status': true});
      updateBadgeVisibility();
    }
  }

  void resetBadge() {
    // 모든 알림을 초기화 (뱃지 지우기)
    _badgeBox.clear();
    updateBadgeVisibility();
  }

  void hideBadge() {
    // 강제로 뱃지를 숨기기
    isBadgeVisible.value = false;
  }
}
