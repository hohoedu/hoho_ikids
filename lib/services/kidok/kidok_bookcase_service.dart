import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 키독 책장 리스트
Future<void> kidokBookcaseService(keycode) async {
  String url = dotenv.get('KIDOK_BOOKCASE_URL');
  final kidokBookcaseController = Get.put(KidokBookcaseDataController());
  final userData = Get.find<UserDataController>();
  final Map<String, dynamic> requestData = {
    'yy': userData.userData!.year,
    'keycode': keycode,
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
        final List<KidokBookcaseData> kidokBookcaseDataList =
            (resultList['data'] as List)
                .map((json) => KidokBookcaseData.fromJson(json))
                .toList();
        kidokBookcaseController.setKidokBookcaseDataList(kidokBookcaseDataList);
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
