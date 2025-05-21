import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_goldenbell_data.dart';
import 'package:hani_booki/_data/hani/hani_insung_list_data.dart';
import 'package:hani_booki/_data/hani/hani_song_list_data.dart';
import 'package:hani_booki/screens/hani/hani_goldenbell/hani_goldenbell_screen.dart';
import 'package:hani_booki/screens/hani/insung_list/insung_list_screen.dart';
import 'package:hani_booki/screens/hani/quiz/quiz_screen.dart';
import 'package:hani_booki/screens/hani/song_list/song_list_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 인성이야기
Future<void> haniInsungListService(id, keyCode, year) async {
  String url = dotenv.get('HANI_INSUNG_LIST_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
  };
  Logger().d(requestData);

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  Logger().d(response);

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      final resultValue = responseData['result'];
      final List<dynamic> resultData = responseData['data'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        List<HaniInsungListData> haniInsungList = resultData.map((item) => HaniInsungListData.fromJson(item)).toList();
        final haniInsungListDataController = Get.put(HaniInsungListController());
        haniInsungListDataController.setHaniInsungsList(haniInsungList);

        Get.to(() => InsungListScreen(keyCode: keyCode));
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
