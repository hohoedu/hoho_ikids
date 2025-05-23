import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/screens/video_player/video_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

Future<void> haniSongFiveService(id, keyCode, year, hosu) async {
  String url = '';
  if (keyCode.substring(0, 1) == 'Y') {
    url = dotenv.get('HANI_SONG_Y5_URL');
  }
  if (keyCode.substring(0, 1) == 'G') {
    url = dotenv.get('HANI_SONG_G5_URL');
  }

  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
    'hosu': hosu,
  };
  Logger().d(requestData);
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  Logger().d(response);
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);

      // 응답 결과가 있는 경우
      if (responseData['result'] == "0000") {
        if(responseData['han'] != null){
          Get.off(
                () => VideoScreen(
              content: 'han',
              videoId: responseData['han'],
              keyCode: keyCode,
            ),
          );
        }
        if (responseData['song'] != null) {
          Get.off(
            () => VideoScreen(
              content: 'Song',
              videoId: responseData['song'],
              keyCode: keyCode,
            ),
          );
        }
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '영상을 재생할 수 없습니다.',
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
