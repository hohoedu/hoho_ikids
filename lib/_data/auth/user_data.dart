import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class UserData {
  final String id;
  final String username;
  final String schoolId;
  final String schoolName;
  final String year;
  final String parentTel;
  final String siblingCount;
  final String userType;

  UserData({
    required this.id,
    required this.username,
    required this.schoolId,
    required this.schoolName,
    required this.year,
    required this.parentTel,
    required this.siblingCount,
    required this.userType,
  });

  UserData.fromJson(Map<String, dynamic> json, this.id)
      : username = json['cname'] ?? '',
        schoolId = json['schoolid'] ?? '',
        schoolName = json['schoolname'] ?? '',
        year = json['yy'] ?? '',
        parentTel = json['ptel'] ?? '',
        siblingCount = json['ptelcnt'] == '' ? '0' : json['ptelcnt'],
        userType = json['user_gb'];

  UserData copyWith({
    String? id,
    String? username,
    String? schoolId,
    String? schoolName,
    String? year,
    String? parentTel,
    String? siblingCount,
    String? userType,
  }) {
    return UserData(
      id: id ?? this.id,
      username: username ?? this.username,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      year: year ?? this.year,
      parentTel: parentTel ?? this.parentTel,
      siblingCount: siblingCount ?? this.siblingCount,
      userType: userType ?? this.userType,
    );
  }
}

class UserDataController extends GetxController {
  final Rx<UserData?> _userData = Rx<UserData?>(null);

  void setUserData(UserData userData) {
    _userData.value = userData;
    update();
  }

  UserData? get userData => _userData.value;

  void updateUserData({
    required String id,
    required String username,
    required String schoolId,
    required String schoolName,
    required String year,
  }) {
    if (_userData.value != null) {
      // 기존 데이터가 있을 경우 copyWith를 사용해 덮어쓰기
      _userData.value = _userData.value!.copyWith(
        id: id,
        username: username,
        schoolId: schoolId,
        schoolName: schoolName,
        year: year,
      );
    } else {
      // 기존 데이터가 없으면 새로 생성 (parentTel, siblingCount는 기본값으로 처리)
      _userData.value = UserData(
        id: id,
        username: username,
        schoolId: schoolId,
        schoolName: schoolName,
        year: year,
        parentTel: '',
        siblingCount: '',
        userType: '',
      );
    }
    update();
  }
}
