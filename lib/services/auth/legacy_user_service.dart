import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/services/auth/login_service.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 기존 회원 로그인
Future<void> legacyUserService(
    {id,
    password,
    className,
    classCode1,
    classCode2,
    isAutoLoginChecked}) async {
  String url = dotenv.get('LEGACY_USER_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'classname': className,
    'pin1': classCode1,
    'pin2': classCode2,
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
        oneButtonDialog(
            title: '코드 등록',
            content: '등록되었습니다.\n다시 로그인해주세요.',
            onTap: () {
              Get.to(() => const LoginScreen());
            },
            buttonText: '확인');
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        showCodeErrorDialog(
          title: '로그인',
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
