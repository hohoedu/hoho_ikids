import 'package:get/get.dart';

class NotificationController extends GetxController {
  var allChecked = false.obs;
  var categories = <String, RxBool>{
    '신규 E-BOOK': false.obs,
    '언어분석 리포트': false.obs,
    '교육정보 및 공지사항': false.obs,
  };

  void toggleAll(bool value) {
    allChecked.value = value;
    categories.forEach((key, check) {
      check.value = value;
    });
  }

  void toggleCategory(String key, bool value) {
    categories[key]!.value = value;
    if (categories.values.every((element) => element.value)) {
      allChecked.value = true;
    } else {
      allChecked.value = false;
    }
  }
}
