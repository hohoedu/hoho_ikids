import 'package:get/get.dart';

class UserHaniData {
  final String keyCode;
  final String section;
  final String date;
  final String imagePath;

  UserHaniData({
    required this.keyCode,
    required this.section,
    required this.date,
    required this.imagePath,
  });

  UserHaniData.fromJson(Map<String, dynamic> json)
      : keyCode = json['keycode'],
        section = json['bookgb'],
        date = json['dday'],
        imagePath = json['img'];
}

class UserHaniDataController extends GetxController {
  List<UserHaniData> _userHaniDataList = <UserHaniData>[].obs;

  void setUserHaniDataList(List<UserHaniData> userHaniDataList) {
    _userHaniDataList = List.from(userHaniDataList);
    update();
  }

  List<UserHaniData> get userHaniDataList => _userHaniDataList;
}
