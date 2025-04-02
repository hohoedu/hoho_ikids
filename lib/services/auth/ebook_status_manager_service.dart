import 'dart:convert';
import 'dart:ffi';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_ebook_data.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/services/booki/booki_list_manager_service.dart';
import 'package:hani_booki/services/booki/booki_list_service.dart';
import 'package:hani_booki/services/hani/hani_list_manager_service.dart';
import 'package:hani_booki/services/hani/hani_list_service.dart';
import 'package:hani_booki/services/sibling_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 이북 사용 여부 확인
Future<void> ebookStatusManagerService(schoolId, year) async {
  final userEbookDataController = Get.put(UserEbookDataController(), permanent: true);
  String url = dotenv.get('M_EBOOK_USE_URL');
  final Map<String, dynamic> requestData = {
    'schoolid': schoolId,
    'yy': year,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "000") {
        final UserEbookData userEbookData = UserEbookData.fromJson(resultList);

        userEbookDataController.setUserEbookData(userEbookData);
        if (resultList['Hani'] == 'Y') {
          await haniListManagerService(schoolId, year);
        }
        if (resultList['Booki'] == 'Y') {
          await bookiListManagerService(schoolId, year);
        }
        Get.off(() => const HomeScreen());
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
