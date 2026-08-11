import 'dart:convert';

import 'package:hani_booki/_core/env.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:logger/logger.dart';

Future<Map<String, dynamic>?> reportReadService(String keyCode) async {
  final userData = Get.find<UserDataController>();
  String url = Env.get('REPORT_READ_URL');
  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'gamok': keyCode.substring(0, 1),
    'yy': userData.userData!.year
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultData = json.decode(response.data);

      return {
        'read_yn': resultData['read_yn'],
        'hosu': resultData['hosu'],
      };
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
