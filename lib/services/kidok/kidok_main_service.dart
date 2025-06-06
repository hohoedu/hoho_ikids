import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/kidok/kidok_main_data.dart';
import 'package:hani_booki/screens/kidok/kidok_home/kidok_home_screen.dart';
import 'package:hani_booki/services/kidok/kidok_bookcase_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 키독 메인 도서 리스트
Future<void> kidokMainService(year, keyCode, isSibling) async {
  String url = dotenv.get('KIDOK_MAIN_URL');
  final kidokMainController = Get.put(KidokMainDataController());
  final Map<String, dynamic> requestData = {
    'yy': year,
    'keycode': keyCode,
  };

  Logger().d(requestData);
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  Logger().d(response);
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<KidokMainData> kidokDataList =
            (resultList['data'] as List).map((json) => KidokMainData.fromJson(json)).toList();
        kidokMainController.setKidokMainDataList(kidokDataList);
        await kidokBookcaseService(keyCode);
        Get.to(() => KidokHomeScreen(
              keyCode: keyCode,
              isSibling: isSibling,
            ));
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
