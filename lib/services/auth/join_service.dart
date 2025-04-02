import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/services/auth/login_service.dart';
import 'package:hani_booki/utils/encryption.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/dialog.dart';

import 'package:logger/logger.dart';

// 회원가입
Future<void> joinService() async {
  String url = dotenv.get('JOIN_URL');
  final joinController = Get.find<JoinController>();

  final Map<String, dynamic> requestData = {
    'id': joinController.joinDTO.value.id,
    'cname': joinController.joinDTO.value.username,
    'pwd': md5_convertHash(joinController.joinDTO.value.password),
    'ptel': removeHyphen(joinController.joinDTO.value.parentTel),
    'classname': joinController.joinDTO.value.className,
    'chk1': joinController.joinDTO.value.check1,
    'chk2': joinController.joinDTO.value.check2,
    'chk3': joinController.joinDTO.value.check3,
    'chk4': joinController.joinDTO.value.check4,
    'pin1': joinController.joinDTO.value.classCode1,
    'pin2': joinController.joinDTO.value.classCode2,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        Get.offAll(() => const LoginScreen());
        loginService(
          joinController.joinDTO.value.id,
          joinController.joinDTO.value.password,
          false
        );
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        showCodeErrorDialog(
          title: '회원가입',
          content: splitWithNewLine(resultList['message']),
          confirm: () {
            Get.back();
          },
          confirmText: '확인',
        );
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
