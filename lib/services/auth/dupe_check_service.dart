import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:logger/logger.dart';

// 아이디 중복 확인
Future<String> dupeCheckService(String id) async {
  String url = dotenv.get('DUPE_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "9999") {
        final String message = resultList['message'];
        return message;
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      return '사용 가능한 아이디입니다.';
    }
    return '사용 가능한 아이디 입니다';
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
  return '';
}

class JoinInputController extends GetxController {
  RxString message = ''.obs;
  RxBool isComplete = false.obs;
  Rx<Color> messageColor = Colors.red.obs;

  Future<void> checkDuplicateId(String id) async {
    if (id.isEmpty) {
      message.value = '아이디를 입력해주세요.';
      messageColor.value = Colors.red;
      return;
    }
    final validationMessage = await dupeCheckService(id);
    if (validationMessage == '사용 가능한 아이디입니다.') {
      message.value = validationMessage;
      messageColor.value = Colors.green;
      isComplete.value = true;
    } else {
      message.value = validationMessage;
      messageColor.value = Colors.red;
      isComplete.value = false;
    }
  }

  void resetValidationMessage() {
    message.value = '';
    messageColor.value = Colors.red;
  }
}
