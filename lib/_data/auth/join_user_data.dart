import 'package:get/get.dart';

class JoinUserData {
  final String schoolName;
  final String schoolId;
  final String className;
  final String age;

  JoinUserData({
    required this.schoolName,
    required this.schoolId,
    required this.className,
    required this.age,
  });

  factory JoinUserData.fromJson(Map<String, dynamic> json) {
    String schoolName = json['schoolname'] ?? '유치원 이름';
    String schoolId = json['schoolid'] ?? '유치원 아이디';
    String age = json['age'] ?? '나이';
    String className = json['className'] ?? '반 이름';

    return JoinUserData(
      schoolName: schoolName,
      schoolId: schoolId,
      className: className,
      age: age,
    );
  }
}

class JoinUserDataController extends GetxController {
  JoinUserData? _joinUserData;

  void setJoinData(JoinUserData joinUserData) {
    _joinUserData = joinUserData;
    update();
  }

  JoinUserData? get joinUserData => _joinUserData;
}
