import 'package:get/get.dart';

class UserBookiData {
  final String keyCode;
  final String section;
  final String date;
  final String imagePath;

  UserBookiData({
    required this.keyCode,
    required this.section,
    required this.date,
    required this.imagePath,
  });

  UserBookiData.fromJson(Map<String, dynamic> json)
      : keyCode = json['keycode'],
        section = json['bookgb'] ?? '',
        date = json['dday'],
        imagePath = json['img'];
}

class UserBookiDataController extends GetxController {
  List<UserBookiData> _userBookiDataList = <UserBookiData>[].obs;

  void setUserBookiDataList(List<UserBookiData> userBookiDataList) {
    _userBookiDataList = List.from(userBookiDataList.reversed.toList());
    update();
  }

  List<UserBookiData> get userBookiDataList => _userBookiDataList;
}
