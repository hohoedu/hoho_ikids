import 'dart:convert';

import 'package:hani_booki/_core/env.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/booki/booki_basket_data.dart';
import 'package:hani_booki/screens/booki/basket/basket_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 부키 바구니
Future<void> bookiBasketService(id, keyCode, year) async {
  String url = Env.get('BOOKI_BASKET_URL');

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
      // 응답 {"result": "0000", "gamok": "K", "count": 10, "list": [{gamok, ilno, person_img, answer_img1~3, wrong_img1~3}, ...]}
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];
      final List<dynamic> list = resultList['list'] ?? [];

      // 응답 결과가 있는 경우
      if (resultValue == "0000" && list.isNotEmpty) {
        List<BookiBasketData> bookiBasketDataList = list.map((item) => BookiBasketData.fromJson(item)).toList();

        final BookiBasketDataController bookiBasketDataController = Get.put(BookiBasketDataController());
        bookiBasketDataController.setBookiBasketDataList(bookiBasketDataList);

        Get.to(() => const BasketScreen());
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
