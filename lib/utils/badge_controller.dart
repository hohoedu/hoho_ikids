import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class BadgeController extends GetxController {
  late Box<Map> _badgeBox;
  var isBadgeVisible = true.obs;
  RxInt unReadCount = 0.obs;

  Future<void> initHive(String userId) async {
    _badgeBox = await Hive.openBox<Map>(userId);
    calculateUnread(); // 초기 계산
    _badgeBox.watch().listen((event) {
      calculateUnread(); // 데이터 변경 시 재계산
    });
    updateBadgeVisibility();
  }

  void updateBadgeVisibility() {
    isBadgeVisible.value = _badgeBox.values.any((value) => value['status'] == false);
  }

  void setUnreadNoticesFromList(List<Map<String, dynamic>> list) {
    for (var item in list) {
      final idx = item['idx'].toString();
      if (!_badgeBox.containsKey(idx)) {
        _badgeBox.put(idx, {'notificationIndex': idx, 'status': false});
      }
    }
    updateBadgeVisibility();
    update();
  }

  void saveNotificationStatus(String index, bool status) {
    _badgeBox.put(index.toString(), {'notificationIndex': index, 'status': status});
    updateBadgeVisibility();
  }

  void markNotificationAsRead(String index) async {
    // 알림 읽기 처리
    if (_badgeBox.containsKey(index.toString())) {
      await _badgeBox.put(index.toString(), {'notificationIndex': index, 'status': true});
      updateBadgeVisibility();
      update();
    }
  }

  bool isRead(String idx) {
    return _badgeBox.get(idx)?['status'] == true;
  }

  void resetBadge() {
    // 모든 알림을 초기화 (뱃지 지우기)
    _badgeBox.clear();
    updateBadgeVisibility();
  }

  void calculateUnread() {
    final count = _badgeBox.values
        .where((notification) => notification['status'] == false)
        .length;
    unReadCount.value = count;
  }

  void hideBadge() {
    // 강제로 뱃지를 숨기기
    isBadgeVisible.value = false;
  }
}
