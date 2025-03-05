import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class UserEbookData {
  final bool isHani;
  final bool isBooki;

  UserEbookData({
    required this.isHani,
    required this.isBooki,
  });

  UserEbookData.fromJson(Map<String, dynamic> json)
      : isHani = json['Hani'] == 'Y' ? true : false,
        isBooki = json['Booki'] == 'Y' ? true : false;

  UserEbookData copyWith({bool? isHani, bool? isBooki}) {
    return UserEbookData(
      isHani: isHani ?? this.isHani,
      isBooki: isBooki ?? this.isBooki,
    );
  }
}

class UserEbookDataController extends GetxController {
  final Rx<UserEbookData?> _userEbookData = Rx<UserEbookData?>(null);

  void setUserEbookData(UserEbookData userEbookData) {
    _userEbookData.value = userEbookData;
    update();
  }
  UserEbookData? get userData => _userEbookData.value;
}
