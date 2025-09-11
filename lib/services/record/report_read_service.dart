import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:logger/logger.dart';

// 학습 기록 상태
Future<void> reportReadService(String keyCode, String hosu) async {
  final userData = Get.find<UserDataController>();
  String url = dotenv.get('REPORT_READ_URL');

  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'gamok': keyCode.substring(keyCode.length - 1),
    'yy': userData.userData!.year,
    'hosu': hosu
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];
      return;
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
