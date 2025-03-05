import 'package:get/get.dart';
import 'package:hani_booki/utils/encryption.dart';

class JoinDTO {
  final String? id;
  final String? username;
  final String password;
  final String? classCode1;
  final String? classCode2;
  final String parentTel;
  final String? className;
  final String check1;
  final String check2;
  final String check3;
  final String check4;

  JoinDTO({
    this.id,
    this.username,
    this.password = '',
    this.classCode1,
    this.classCode2,
    this.parentTel='',
    this.className,
    this.check1 = 'N',
    this.check2 = 'N',
    this.check3 = 'N',
    this.check4 = 'N',
  });

  JoinDTO copyWith({
    String? id,
    String? password,
    String? username,
    String? classCode1,
    String? classCode2,
    String? className,
    String? parentTel,
    String? check1,
    String? check2,
    String? check3,
    String? check4,
  }) {
    return JoinDTO(
      id: id ?? this.id,
      password: password ?? this.password,
      username: username ?? this.username,
      classCode1: classCode1 ?? this.classCode1,
      classCode2: classCode2 ?? this.classCode2,
      className: className ?? this.className,
      parentTel: parentTel ?? this.parentTel,
      check1: check1 ?? this.check1,
      check2: check2 ?? this.check2,
      check3: check3 ?? this.check3,
      check4: check4 ?? this.check4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pwd': md5_convertHash(password),
      'cname': username,
      'pin': classCode1,
      'pin2': classCode2,
      'classname': className,
      'ptel': parentTel,
      'chk1': check1,
      'chk2': check2,
      'chk3': check3,
      'chk4': check4,
    };
  }

  @override
  String toString() {
    return 'JoinDto(id: $id, password: $password, username: $username, classCode1: $classCode1, classCode2: $classCode2, className: $className, parentTel: $parentTel, check1: $check1, check2: $check2, check3: $check3, check4: $check4)';
  }
}

class JoinController extends GetxController {
  var joinDTO = JoinDTO().obs;

  void updateIdAndPassword(String id, String password) {
    joinDTO.value = joinDTO.value.copyWith(id: id, password: password);
  }

  void updateClassCodes(String classCode1, String classCode2) {
    joinDTO.value =
        joinDTO.value.copyWith(classCode1: classCode1, classCode2: classCode2);
  }

  void updateUsernameAndClassName(String username, String className) {
    joinDTO.value = joinDTO.value.copyWith(username: username, className: className);
  }

  void updateParentTel(String parentTel) {
    joinDTO.value = joinDTO.value.copyWith(parentTel: parentTel);
  }

  void updateCheckBoxes(bool check1, bool check2, bool check3) {
    joinDTO.value = joinDTO.value.copyWith(
      check1: check1 == true ? "Y" : "N",
      check2: check2 == true ? "Y" : "N",
      check3: check3 == true ? "Y" : "N",
    );
  }
}
