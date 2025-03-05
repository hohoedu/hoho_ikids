import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/screens/video_player/video_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 부키 동요
Future<void> bookiSongService(id, keycode,year) async {
  String url = dotenv.get('BOOKI_SONG_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keycode,
    'yy': year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);

      // 응답 결과가 있는 경우
      if (responseData['result'] == "0000") {
        if (responseData['song'] != null) {
          Get.to(
            () => VideoScreen(content: 'song',videoId: responseData['song'], keyCode: keycode,),
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
