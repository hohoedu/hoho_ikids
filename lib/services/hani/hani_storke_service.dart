import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_stroke_data.dart';
import 'package:hani_booki/screens/hani/stroke/stroke_screen.dart';
import 'package:hani_booki/screens/video_player/video_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 동요
Future<void> haniStrokeService(id, keyCode, year) async {
  final haniStrokeDataController = Get.put(HaniStrokeDataController());
  String url = dotenv.get('HANI_STROKE_URL');

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
      final List<dynamic> responseData = json.decode(response.data);

      // 응답 결과가 있는 경우
      if (responseData[0]['result'] == "0000") {
        final List<HaniStrokeData> haniStrokeDataList =
            responseData.map((json) => HaniStrokeData.fromJson(json)).toList();
        haniStrokeDataController.setHaniStrokeDataList(haniStrokeDataList);

        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        // (옵션) 화면 회전 애니메이션이 완료될 시간을 고려해 짧은 딜레이 추가
        await Future.delayed(const Duration(milliseconds: 300));

        Get.to(() => StrokeScreen(keyCode: keyCode));
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '데이터를 불러올 수 없습니다.',
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
