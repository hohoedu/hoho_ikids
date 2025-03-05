import 'package:get/get.dart';

class UserCodeData {
  final String pin;
  final String className;
  final String category;
  final String age;

  UserCodeData({
    required this.pin,
    required this.className,
    required this.category,
    required this.age,
  });

  UserCodeData.fromJson(Map<String, dynamic> json)
      : pin = json['pin'],
        className = json['gb_str'],
        category = json['gb_str2'],
        age = json['gb_age'];
}

class UserCodeDataController extends GetxController {
  List<UserCodeData> _userCodeDataList = <UserCodeData>[].obs;

  void setUserCodeDataList(List<UserCodeData> userCodeDataList) {
    _userCodeDataList = List.from(userCodeDataList);
    update();
  }

  List<UserCodeData> get userCodeDataList => _userCodeDataList;
}
