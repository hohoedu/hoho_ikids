import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/star/star_data.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/screens/home/sibling_screen.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 형제 리스트 조회
Future<void> siblingService(tel) async {
  final siblingData = Get.put(SiblingDataController(), permanent: true);
  final userData = Get.put(UserDataController());
  String url = dotenv.get('SIBLING_URL');

  final Map<String, dynamic> requestData = {'ptel': tel};

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<SiblingData> siblingDataList = (resultList['data'] as List)
            .map((json) => SiblingData.fromJson(json))
            .toList();
        siblingData.setSiblingDataList(siblingDataList);

        if (siblingDataList.length >= 2) {
          Get.offAll(() => SiblingScreen());
        } else if(siblingDataList.length == 1){
          userData.updateUserData(
            id: siblingData.siblingDataList[0].id,
            username: siblingData.siblingDataList[0].username,
            schoolId: siblingData.siblingDataList[0].schoolId,
            schoolName: siblingData.siblingDataList[0].schoolName,
            year: userData.userData!.year,
          );
        }
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
