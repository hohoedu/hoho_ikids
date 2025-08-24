import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/booki/booki_stroke_data.dart';
import 'package:hani_booki/screens/booki/booki_stroke/booki_stroke_horizontal_screen.dart';
import 'package:hani_booki/screens/booki/booki_stroke/booki_stroke_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 부키 획순 따라쓰기
Future<void> bookiStrokeService(id, String keyCode, year) async {
  final bookiStrokeDataController = Get.put(BookiStrokeDataController());
  String url = dotenv.get('BOOKI_STROKE_URL');
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
        final List<BookiStrokeData> bookiStrokeDataList =
            responseData.map((json) => BookiStrokeData.fromJson(json)).toList();
        bookiStrokeDataController.setBookiStrokeDataList(bookiStrokeDataList);
        if (int.parse(keyCode.substring(2, 4)) >= 8) {
          // if (int.parse('JA08LH56'.substring(2, 4)) >= 8) {
          Get.to(
            () => BookiStrokeHorizontalScreen(
              keyCode: keyCode,
            ),
          );
        } else {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          await Future.delayed(const Duration(milliseconds: 300));

          Get.to(() => BookiStrokeScreen(keyCode: keyCode));
        }
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
