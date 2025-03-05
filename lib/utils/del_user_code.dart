import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_code_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/mypage/mypage_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 유저 코드 가져오기
Future<void> delUserCode(pin) async {
  String url = dotenv.get('USER_CODE_DEL_URL');
  final userData = Get.find<UserDataController>();
  final userCodeData = Get.put(UserCodeDataController());
  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'yy': userData.userData!.year,
    'pin': pin
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
        Logger().d('삭제');
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        Logger().d('삭제 실패');
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
