import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_question_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 키독 문제 풀이
Future<void> kidokResultService(List<int?> selectedAnswers, bookCode, keycode) async {
  final userData = Get.find<UserDataController>();
  String url = dotenv.get('KIDOK_SAVE_URL');
  final Map<String, dynamic> requestData = {
    'yy': userData.userData!.year,
    'bcode': bookCode,
    'keycode': keycode,
    'id': userData.userData!.id,
  };

  for (int i = 0; i < selectedAnswers.length; i++) {
    requestData['q${i + 1}'] = (selectedAnswers[i] ?? -1) + 1;
  }

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultValue = jsonDecode(response.data);
      // 응답 결과가 있는 경우
      if (resultValue['result'] == "0000") {
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '데이터가 없습니다.',
          onTap: () => Get.back(),
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
