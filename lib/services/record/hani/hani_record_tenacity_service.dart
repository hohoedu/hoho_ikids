import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/record/hani_record_tenacity_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 하니 학습 기록 (인성활동)
Future<void> haniRecordTenacityService(teacherId, pin, hosu, schoolId) async {
  final recordTenacityDataController = Get.put(HaniRecordTenacityDataController());
  final userData = Get.find<UserDataController>();
  String url = '';
  if (userData.userData!.userType == 'M') {
    url = dotenv.get('M_HANI_REPORT_TENACITY_URL');
  } else {
    url = dotenv.get('HANI_REPORT_TENACITY_URL');
  }

  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'yy': userData.userData!.year,
    'teacherid': teacherId,
    'pin': pin,
    'hosu': hosu,
    'schoolid': schoolId
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
        final HaniRecordTenacityData recordTenacityData = HaniRecordTenacityData.fromJson(resultList['data'][0]);

        recordTenacityDataController.setHaniRecordTenacityData(recordTenacityData);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        recordTenacityDataController.clearData();
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
