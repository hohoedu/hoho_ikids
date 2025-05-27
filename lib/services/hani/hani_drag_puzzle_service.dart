import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_drag_puzzle_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 창의표현 퍼즐
Future<void> haniDragPuzzleService(id, keyCode, year) async {
  final dragPuzzleData = Get.put(HaniDragPuzzleDataController());
  String url = dotenv.get('HANI_PUZZLE_Y5_URL');
  Logger().d(url);
  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  Logger().d(response);
  print('어휘만들기 = ${response.data}');
  try {
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      final resultValue = responseData['result'];
      final List<dynamic> resultData = responseData['data'];

      if (resultValue == "0000") {
        List<HaniDragPuzzleData> dragPuzzleDataList =
            resultData.map((item) => HaniDragPuzzleData.fromJson(item)).toList();

        dragPuzzleData.setDragPuzzleDataList(dragPuzzleDataList);


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
