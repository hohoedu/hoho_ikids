import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/record/hani_record_home_data.dart';
import 'package:hani_booki/services/record/hani/hani_record_highfive_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_learning_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_tenacity_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 학습기록 홈
Future<void> haniRecordHomeService() async {
  final recordHomeDataController = Get.put(HaniRecordHomeDataController());
  final userData = Get.find<UserDataController>();
  String url = '';
  if (userData.userData!.userType == 'M') {
    url = dotenv.get('M_HANI_REPORT_HOME_URL');
  } else {
    url = dotenv.get('HANI_REPORT_HOME_URL');
  }

  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'yy': userData.userData!.year,
  };
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      int index = 0;
      if (userData.userData!.userType == "M") {
        final random = Random();
        index = random.nextInt(resultList['data'].length);
      }
      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final HaniRecordHomeData recordHomeData = HaniRecordHomeData.fromJson(resultList['data'][index]);
        recordHomeDataController.setHaniRecordHomeData(recordHomeData);
        await haniRecordLearningService(
          recordHomeData.teacherId,
          recordHomeData.keyCode,
          recordHomeData.category,
          recordHomeData.schoolId,
        );
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        recordHomeDataController.clearData();
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
