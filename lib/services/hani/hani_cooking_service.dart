import 'dart:convert';

import 'package:hani_booki/_core/env.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/hani/hani_cooking_data.dart';
import 'package:hani_booki/screens/hani/cooking/cooking_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 요리
Future<void> haniCookingService(id, keyCode, year) async {
  String url = Env.get('HANI_COOKING_URL');
  String gamok = keyCode.toString().substring(0, 1);
  final Map<String, dynamic> requestData = {
    'id': id,
    'keycode': keyCode,
    'yy': year,
    'gamok': gamok,
  };

  try {
    // HTTP POST 요청 (네트워크 오류도 아래 catch 로 받음)
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      // 응답 {"result": "0000", "gamok": "S", "main_img": ..., "count": 10, "list": [{gamok, ilno, munje, ans1~4·ans1~4_img, wrong1~2·wrong1~2_img}, ...]}
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];
      final List<dynamic> list = resultList['list'] ?? [];
      Logger().d(response);
      // 응답 결과가 있는 경우
      if (resultValue == "0000" && list.isNotEmpty) {
        List<HaniCookingData> dataList = list.map((item) => HaniCookingData.fromJson(item)).toList();

        final HaniCookingDataController haniCookingDataController = Get.put(HaniCookingDataController());
        haniCookingDataController.setHaniCookingDataList(dataList, mainImg: resultList['main_img'] ?? '');

        Get.to(() => const CookingScreen());
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
