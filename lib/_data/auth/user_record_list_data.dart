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
  List<UserRecordListData> _userrRecordListDataList = <UserRecordListData>[].obs;

  void setUserRecordListDataList(List<dynamic> userrRecordListDataList) {
    _userrRecordListDataList = List.from(userrRecordListDataList);
    update();
  }

  List<UserRecordListData> get userrRecordListDataList => _userrRecordListDataList;
}
