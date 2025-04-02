import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_screen.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:hani_booki/utils/connectivityController.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 이북 콘텐츠 리스트
Future<void> haniContentService(keyCode, schoolId, year) async {
  final haniHomeController = Get.put(HaniHomeDataController());

  String url = dotenv.get('HANI_EBOOK_CONTENT_LIST_URL');
  final Map<String, dynamic> requestData = {
    'keycode': keyCode,
    'schoolid': schoolId,
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
        haniHomeController.setHaniHomeDataMap(resultList['data']);
        await totalStarService(keyCode);
        Get.to(() => HaniHomeScreen(keyCode: keyCode));
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
