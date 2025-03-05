import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/screens/booki/booki_home/booki_home_screen.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 부키 이북 콘텐츠 리스트
Future<void> bookiContentService(keyCode, schoolId, year) async {
  String url = dotenv.get('BOOKI_EBOOK_CONTENT_LIST_URL');
  final bookiHomeController = Get.put(BookiHomeDataController());
  final Map<String, dynamic> requestData = {
    'schoolid': schoolId,
    'keycode': keyCode,
    'yy': year,
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
        bookiHomeController.setBookiHomeDataMap(resultList['data']);
       await totalStarService(keyCode);
        Get.to(() => BookiHomeScreen(keyCode : keyCode));
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
