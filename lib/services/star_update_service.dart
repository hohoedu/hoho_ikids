import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 별포인트 업데이트
/*
부키
동요  : song
동화  : storu
골든밸 : bekk
그림맞추기  : img
디른그림찾기 :  find
키독 : kido

하니
자원송 : song
한자송(영: 한자송.수재:낱말송) : han
인성이야기 : insung
획순따라쓰기 : write
쓱싹쓱싹(영재) : clean
한자카드놀이 : card
키독 : kido
형.음.의(수재.신동) : puzzle
골든벨(신동) : bell
*/

Future<void> starUpdateService(type, keyCode) async {
  Logger().d('호출 = $type');
  final userController = Get.find<UserDataController>();
  String url = dotenv.get('STAR_UPDATE_URL');

  final Map<String, dynamic> requestData = {
    'id': userController.userData!.id,
    'keycode': keyCode,
    'gb': type,
    'yy': userController.userData!.year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);

      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        totalStarService(keyCode);
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
