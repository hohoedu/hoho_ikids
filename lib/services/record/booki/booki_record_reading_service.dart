import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/record/booki_record_reading_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

Future<void> bookiRecordReadingService(teacherId, pin, hosu, schoolId) async {
  final recordTenacityDataController = Get.find<BookiRecordReadingDataController>();
  final userData = Get.find<UserDataController>();
  String url = '';
  if (userData.userData!.userType == 'M') {
    url = dotenv.get('M_BOOKI_REPORT_TENACITY_URL');
  } else {
    url = dotenv.get('BOOKI_REPORT_TENACITY_URL');
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
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      if (resultValue == "0000") {
        final List<BookiRecordReadingData> readingDataList =
            (resultList['data'] as List).map((json) => BookiRecordReadingData.fromJson(json)).toList();

        // RxList에 데이터를 저장
        recordTenacityDataController.setBookiRecordReadingListData(readingDataList);
      } else {
        recordTenacityDataController.clearData();
      }
    }
  } catch (e) {
    Logger().d('에러 발생: $e');
  }
}
