import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/join_user_data.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 가입 코드 확인
Future<bool> joinCodeService(TextEditingController classCode) async {
  final JoinUserDataController joinUserDataController =
      Get.put(JoinUserDataController(), permanent: true);
  String url = dotenv.get('JOIN_CODE_URL');

  final Map<String, dynamic> requestData = {
    'keycode': classCode.text,
  };
  try {
    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        JoinUserData joinUserData = JoinUserData.fromJson(resultList);
        joinUserDataController.setJoinData(joinUserData);

        oneButtonDialog(
          title: '회원가입',
          content: '인증되었습니다.\n유치원이름: ${resultList['schoolname']}',
          onTap: () {
            Get.back();
          },
          buttonText: '확인',
        );
        return true;
      }

      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        showCodeErrorDialog(
          title: '기관코드 오류',
          content: splitWithNewLine(resultList['message']),
          confirm: () {
            classCode.text = '';
            Get.back();
          },
          confirmText: '확인',
        );
        return false;
      }
    } else {
      return false;
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
    return false;
  }
}

// 가입 코드 확인
Future<bool> codeVerifyService(String classCode) async {
  String url = dotenv.get('JOIN_CODE_URL');

  final Map<String, dynamic> requestData = {
    'keycode': classCode,
  };
  try {
    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        return true;
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        return false;
      }
    } else {
      return false;
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
    return false;
  }
}

class CodeVerifyController extends GetxController {
  RxString code1Message = ''.obs;
  RxBool isComplete1 = false.obs;
  Rx<Color> messageColor1 = Colors.red.obs;

  RxString code2Message = ''.obs;
  RxBool isComplete2 = false.obs;
  Rx<Color> messageColor2 = Colors.red.obs;

  // codeIndex: 1이면 가입코드 1, 2이면 가입코드 2를 의미
  Future<void> checkClassCode(
      {required String code, required int codeIndex}) async {
    final validation = await codeVerifyService(code);
    if (codeIndex == 1) {
      if (code.isEmpty || code.length != 7) {
        code1Message.value = '가입코드를 입력해주세요';
        messageColor1.value = Colors.red;
        isComplete1.value = false;
      } else {
        if (validation) {
          code1Message.value = '인증되었습니다.';
          messageColor1.value = Colors.green;
          isComplete1.value = true;
        } else {
          code1Message.value = '기관에서 발송한 가입코드와 일치하지 않습니다.';
          messageColor1.value = Colors.red;
          isComplete1.value = false;
        }
      }
    } else if (codeIndex == 2) {
      if (code.isEmpty || code.length != 7) {
        code2Message.value = '가입코드를 입력해주세요';
        messageColor2.value = Colors.red;
        isComplete2.value = false;
      } else {
        if (validation) {
          code2Message.value = '인증되었습니다.';
          messageColor2.value = Colors.green;
          isComplete2.value = true;
        } else {
          code2Message.value = '기관에서 발송한 가입코드와 일치하지 않습니다.';
          messageColor2.value = Colors.red;
          isComplete2.value = false;
        }
      }
    }
  }

  void resetValidationMessage({required int codeIndex}) {
    if (codeIndex == 1) {
      code1Message.value = '';
      messageColor1.value = Colors.red;
    } else if (codeIndex == 2) {
      code2Message.value = '';
      messageColor2.value = Colors.red;
    }
  }
}
