import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_booki_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/auth/user_record_list_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/screens/hani/hani_home/hani_home_screen.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 학습기록 상단 이미지
Future<void> getRecordList(String keyCode, String type) async {
  String url = dotenv.get('RECORD_LIST_URL');
  final userData = Get.find<UserDataController>();
  final userRecordList = Get.put(UserRecordListDataController());
  String section1 = keyCode.substring(0, 1);
  String section2 = '';

  if (type == 'hani') {
    final haniData = Get.find<UserHaniDataController>();
    section2 = haniData.userHaniDataList[0].section;
  } else {
    final bookiData = Get.find<UserBookiDataController>();
    section2 = bookiData.userBookiDataList[0].section;
  }

  final Map<String, dynamic> requestData = {
    'schoolid': userData.userData!.schoolId,
    'yy': userData.userData!.year,
    'gb1': section1,
    'gb2': section2,
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
        final List<dynamic> userRecordListDataList = resultList['data']
            .map((json) => UserRecordListData.fromJson(json))
            .toList();
        userRecordList.setUserRecordListDataList(userRecordListDataList);
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
