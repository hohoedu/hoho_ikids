import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:logger/logger.dart';

// 전화번호에 가입된 유저 수
Future<String> userCountService(String phone) async {
  String url = dotenv.get('USER_COUNT_URL');

  final currentYear = DateTime
      .now()
      .year;

  final Map<String, dynamic> requestData = {
    'yy': currentYear,
    'ptel': removeHyphen(phone),
  };
  Logger().d(requestData);
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      final resultValue = result['result'];
      Logger().d(result['telcount']);
      // 응답 데이터가 오류일 때("9999": 오류)
      if (resultValue == "9999") {
        final String message = result['message'];
        return message;
      }
      Logger().d(result['telcount']);
      return result['telcount'];
    }
    Logger().d('message');
    return '응답완료';
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
  return '';
}

class UserCountController extends GetxController {
  RxString message = ''.obs;
  RxBool isComplete = false.obs;
  Rx<Color> messageColor = Colors.red.obs;

  Future<void> checkUserCount(String phone) async {
    if (phone.isEmpty) {
      message.value = '전화번호를 입력해주세요.';
      messageColor.value = Colors.red;
      return;
    }
    final validationMessage = await userCountService(phone);
    if (int.parse(validationMessage) < 4) {
      message.value = '사용 가능한 전화번호입니다.';
      messageColor.value = Colors.green;
      isComplete.value = true;
    } else {
      message.value = '더이상 등록하실 수 없습니다.';
      messageColor.value = Colors.red;
      isComplete.value = false;
    }
  }

  void resetValidationMessage() {
    message.value = '';
    messageColor.value = Colors.red;
  }
}
