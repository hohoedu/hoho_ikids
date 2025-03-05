import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_puzzle_data.dart';
import 'package:hani_booki/screens/hani/puzzle/puzzle_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 형음의
Future<void> haniPuzzleService(id, keyCode, year) async {
  String url = dotenv.get('HANI_PUZZLE_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.data);
      final resultValue = responseData[0]['result'];

      if (resultValue == "0000") {
        // 데이터를 그룹화하여 HaniPuzzleData 객체 생성
        Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in responseData) {
          String groupKey = item['voicepath']; // 그룹 키로 voicepath 사용
          if (!groupedData.containsKey(groupKey)) {
            groupedData[groupKey] = [];
          }
          groupedData[groupKey]!.add(item);
        }

        List<HaniPuzzleData> haniPuzzleDataList = groupedData.values
            .map((group) => HaniPuzzleData.fromJson(group))
            .toList();

        final HaniPuzzleDataController haniPuzzleDataController =
            Get.put(HaniPuzzleDataController());

        haniPuzzleDataController.setHaniPuzzleDataList(haniPuzzleDataList);

        Get.to(() => PuzzleScreen(keyCode: keyCode));

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
