import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_Flip_data.dart';
import 'package:hani_booki/screens/hani/flip_card/flip_card_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 카드놀이
Future<void> haniFlipService(id, keyCode, year) async {
  final HaniFlipDataController haniFlipDataController =
      Get.put(HaniFlipDataController());
  String url = dotenv.get('HANI_FLIP_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final List<dynamic> resultList = json.decode(response.data);
      final resultValue = resultList[0]['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        List<HaniFlipData> haniFlipDataList =
            resultList.map((item) => HaniFlipData.fromJson(item)).toList();
        haniFlipDataController.setHaniFlipDataList(haniFlipDataList);

        Get.to(() => FlipCardScreen(keyCode: keyCode));
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
