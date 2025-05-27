import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_goldenbell_data.dart';
import 'package:hani_booki/_data/hani/hani_song_list_data.dart';
import 'package:hani_booki/screens/hani/hani_goldenbell/hani_goldenbell_screen.dart';
import 'package:hani_booki/screens/hani/quiz/quiz_screen.dart';
import 'package:hani_booki/screens/hani/song_list/song_list_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 모아부르기 (영재, 수재 5호)
Future<void> haniSongListService(id, keyCode, year) async {
  String url = '';
  if (keyCode.substring(0, 1) == 'Y') {
    url = dotenv.get('HANI_SONG_LIST_Y_URL');
  }
  if (keyCode.substring(0, 1) == 'G') {
    url = dotenv.get('HANI_SONG_LIST_G_URL');
  }

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
        List<HaniSongListData> haniSongList = resultData.map((item) => HaniSongListData.fromJson(item)).toList();
        final haniSongListDataController = Get.put(HaniSongListController());
        haniSongListDataController.setHaniSongList(haniSongList);

        Get.to(() => SongListScreen(keyCode: keyCode));
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
