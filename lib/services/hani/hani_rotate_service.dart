import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_goldenbell_data.dart';
import 'package:hani_booki/_data/hani/hani_quiz_data.dart';
import 'package:hani_booki/_data/hani/hani_rotate_data.dart';
import 'package:hani_booki/screens/hani/hani_goldenbell/hani_goldenbell_screen.dart';
import 'package:hani_booki/screens/hani/quiz/quiz_screen.dart';
import 'package:hani_booki/screens/hani/rotate/rotate_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 그림맞추기
Future<void> haniRotateService(id, keyCode, year) async {
  String url = dotenv.get('HANI_ROTATE_URL');

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
      final responseData = json.decode(response.data);
      final resultValue = responseData['result'];
      final List<dynamic> resultData = responseData['data'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        List<HaniRotateData> haniRotateDataList = resultData.map((item) => HaniRotateData.fromJson(item)).toList();

        final haniRotateController = Get.put(HaniRotateDataController());
        haniRotateController.setRotateDataList(haniRotateDataList);

        Get.to(() => RotateScreen(keyCode: keyCode));
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
