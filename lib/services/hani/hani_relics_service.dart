import 'dart:convert';

import 'package:hani_booki/_core/env.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_relics_data.dart';
import 'package:hani_booki/screens/hani/relics/relics_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 유물찾기
Future<void> haniRelicsService(id, keyCode, year) async {
  // TODO: .env·env.dart 에 HANI_RELICS_URL 추가 후 build_runner (없으면 Env.get 이 예외)
  String url = Env.get('HANI_RELICS_URL');

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
      // TODO: 응답이 리스트인지 맵인지 스펙 확인
      final List<dynamic> resultList = json.decode(response.data);
      final resultValue = resultList[0]['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        List<HaniRelicsData> haniRelicsDataList = resultList.map((item) => HaniRelicsData.fromJson(item)).toList();

        final HaniRelicsDataController haniRelicsDataController = Get.put(HaniRelicsDataController());
        haniRelicsDataController.setHaniRelicsDataList(haniRelicsDataList);

        Get.to(() => const RelicsScreen());
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
