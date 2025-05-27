import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/star/content_star_data.dart';
import 'package:hani_booki/_data/star/star_data.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 별포인트 확인
Future<void> contentStarService(keyCode, type) async {
  final userData = Get.find<UserDataController>();
  final contentStarDataController = Get.put(ContentStarDataController());
  // String url = dotenv.get('CONTENT_STAR_URL');
  String url = '';
  if (type == 'hani') {
    url = dotenv.get('H_CONTENT_STAR_URL');
  }
  if (type == 'booki') {
    url = dotenv.get('B_CONTENT_STAR_URL');
  }

  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'keycode': keyCode,
    'yy': userData.userData!.year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
Logger().d(requestData);
  try {
    contentStarDataController.contentStarDataList.clear();
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<ContentStarData> contentStarDataList =
            resultList['data'].map<ContentStarData>((json) => ContentStarData.fromJson(json)).toList();

        // 반응형 업데이트
        contentStarDataController.contentStarDataList.value = contentStarDataList;
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {}
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
