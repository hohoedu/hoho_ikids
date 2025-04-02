import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/record/booki_record_highfive_data.dart';
import 'package:hani_booki/_data/record/hani_record_highfive_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 학습 기록 (하이파이브, 언어활동)
Future<void> bookiRecordHighFiveService(teacherId, pin, hosu, schoolId) async {
  final recordHighfiveController = Get.find<BookiRecordHighfiveDataController>(); // <- Get.find() 사용
  final userData = Get.find<UserDataController>();
  String url = '';
  if (userData.userData!.userType == 'M') {
    url = dotenv.get('M_BOOKI_REPORT_HIGHFIVE_URL');
  } else {
    url = dotenv.get('BOOKI_REPORT_HIGHFIVE_URL');
  }

  final Map<String, dynamic> requestData = {
    'id': userData.userData!.id,
    'yy': userData.userData!.year,
    'teacherid': teacherId,
    'pin': pin,
    'hosu': hosu,
    'schoolid': schoolId
  };

  try {
    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      if (resultValue == "0000") {
        final List<BookiRecordHighFiveData> highFiveDataList =
            (resultList['data'] as List).map((json) => BookiRecordHighFiveData.fromJson(json)).toList();

        // 데이터를 업데이트 (assignAll 사용)
        recordHighfiveController.setBookiRecordHighfiveListData(highFiveDataList);
      } else {
        recordHighfiveController.clearData();
      }
    }
  } catch (e) {
    Logger().d('에러 발생: $e');
  }
}
