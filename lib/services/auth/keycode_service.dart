import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 회원 탈퇴
Future<void> keyCodeService(id, pin, yy) async {
  String url = dotenv.get('KEYCODE_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'pin': pin,
    'yy': yy,
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
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        oneButtonDialog(
          title: '안내',
          content: '${resultList['message']}',
          onTap: () {
            Get.back();
          },
          buttonText: '확인',
        );
      }
    }
  }
  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
