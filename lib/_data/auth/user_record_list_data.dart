import 'package:get/get.dart';

class UserRecordListData {
  final String keyCode;
  final String hosu;
  final String imagePath;

  UserRecordListData({
    required this.keyCode,
    required this.hosu,
    required this.imagePath,
  });

  UserRecordListData.fromJson(Map<String, dynamic> json)
      : keyCode = json['keycode'],
        hosu = json['hosu'],
        imagePath = json['img'];
}

class UserRecordListDataController extends GetxController {
  List<UserRecordListData> _userRecordListDataList = <UserRecordListData>[].obs;

  void setUserRecordListDataList(List<dynamic> userRecordListDataList) {
    _userRecordListDataList = List.from(userRecordListDataList);
    update();
  }

  List<UserRecordListData> get userRecordListDataList => _userRecordListDataList;
}
