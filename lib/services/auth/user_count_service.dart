import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:logger/logger.dart';

enum PhoneCheckResult {
  available,
  duplicate,
  exceeded,
  error,
}

// 전화번호에 가입된 유저 수
Future<PhoneCheckResult> userCountService(String phone, {String? pin1, String? pin2, String? cname}) async {
  String url = dotenv.get('USER_COUNT_URL');
  final currentYear = DateTime.now().year;

  if (pin1 == null || cname == null) {
    JoinController joinController = Get.find();
    pin1 = joinController.joinDTO.value.classCode1;
    pin2 = joinController.joinDTO.value.classCode2;
    cname = joinController.joinDTO.value.username;
  }

  final Map<String, dynamic> requestData = {
    'yy': currentYear,
    'ptel': removeHyphen(phone),
    'pin1': pin1,
    'pin2': pin2 ?? '',
    'cname': cname,
  };
  Logger().d(requestData);
  // HTTP POST 요청
  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    Logger().d(response);

    if (response.statusCode != 200) return PhoneCheckResult.error;

    final Map<String, dynamic> result = json.decode(response.data);

    if (result['result'] == "9999") return PhoneCheckResult.error;

    if (result['result'] == "0000") {
      final int telCount = int.tryParse(result['telcount'].toString()) ?? 0;

      if (result['keydouble'] == '1') return PhoneCheckResult.duplicate;
      if (telCount >= 4) return PhoneCheckResult.exceeded;
      return PhoneCheckResult.available;
    }

    return PhoneCheckResult.error;
  } catch (e) {
    Logger().e('userCountService Error: $e');
    return PhoneCheckResult.error;
  }
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
    final result = await userCountService(phone);
    Logger().d('result = $result');
    switch (result) {
      case PhoneCheckResult.available:
        message.value = '사용 가능한 전화번호입니다.';
        messageColor.value = Colors.green;
        isComplete.value = true;
      case PhoneCheckResult.duplicate:
        message.value = '이미 해당 가입코드로 가입이 완료된 전화번호입니다.';
        messageColor.value = Colors.red;
        isComplete.value = false;
      case PhoneCheckResult.exceeded:
        message.value = '더이상 등록하실 수 없습니다.';
        messageColor.value = Colors.red;
        isComplete.value = false;
      case PhoneCheckResult.error:
        message.value = '오류가 발생했습니다.';
        messageColor.value = Colors.red;
        isComplete.value = false;
    }
  }

  void resetValidationMessage() {
    message.value = '';
    messageColor.value = Colors.red;
  }
}
