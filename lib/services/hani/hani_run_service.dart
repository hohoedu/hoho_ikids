import 'dart:convert';

import 'package:hani_booki/_core/env.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_run_data.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니런: 키코드 과정의 동전 한자 목록(no, text)을 받아 게임 시작
// 응답 {"result": "0000", "data": [{"no": "y01", "text": "불 화"}, ...]}
Future<void> haniRunService(id, keyCode, year) async {
  // TODO: .env·env.dart 에 HANI_RUN_URL 추가 후 build_runner (없으면 Env.get 이 예외)
  String url = Env.get('HANI_RUN_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
  };

  try {
    // HTTP POST 요청 (네트워크 오류도 아래 catch 로 받음)
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];
      final List<dynamic> data = resultList['data'] ?? [];

      // 응답 결과가 있는 경우 (정답 하나에 오답·최근 문제 피하기까지 하려면 4개 이상 필요)
      if (resultValue == "0000" && data.length >= 4) {
        List<HaniRunData> haniRunDataList = data.map((item) => HaniRunData.fromJson(item)).toList();

        final HaniRunDataController haniRunDataController = Get.put(HaniRunDataController());
        haniRunDataController.setHaniRunDataList(haniRunDataList);

        Get.to(() => HaniRunScreen(keyCode: keyCode, pool: [for (final d in haniRunDataList) d.toHanja()]));
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
