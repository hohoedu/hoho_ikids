import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_make_word_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 어휘 만들기
Future<void> haniMakeWordService(id, keyCode, year) async {
  final makeWordDataController = Get.put(HaniMakeWordDataController());
  String url = dotenv.get('HANI_MAKE_CARD_URL');
  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
  };
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      final resultValue = responseData['result'];
      final List<dynamic> resultData = responseData['data'];
      if (resultValue == "0000") {
        List<HaniMakeWordData> makeWordDataList = resultData.map((item) => HaniMakeWordData.fromJson(item)).toList();

        makeWordDataController.setMakeWordDataList(makeWordDataList);
      } else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '데이터를 불러올 수 없습니다.',
          onTap: () => Get.back(),
          buttonText: '확인',
        );
      }
    }
  } catch (e) {
    Logger().d('e = $e');
  }
}
