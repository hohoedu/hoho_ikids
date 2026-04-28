import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_chart_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 키독 책장 그래프
Future<void> kidokChartService(String hosu, String keyCode) async {
  final String url = dotenv.get('KIDOK_GRAPH_URL');
  final kidokChartController = Get.put(KidokChartDataController());
  final userData = Get.find<UserDataController>();
  kidokChartController.isLoading.value = true;

  // 화면 재진입 시 이전 데이터 누적 방지 - 조회 전에 초기화
  kidokChartController.clearList();

  final Map<String, dynamic> requestData = {
    'id': userData.userData?.id ?? '',
    'yy': userData.userData?.year ?? '',
    'hosu': hosu,
    'keycode': keyCode,
  };
  Logger().d(requestData);

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      // response.data 타입이 String, Map 이외의 타입(예: List)인 경우도 방어
      Map<String, dynamic> resultList;
      if (response.data is String) {
        resultList = jsonDecode(response.data) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        resultList = response.data as Map<String, dynamic>;
      } else {
        Logger().e('kidokChartService: 예상치 못한 응답 타입 ${response.data.runtimeType}');
        return;
      }

      final String resultValue = resultList['result'] ?? '';

      if (resultValue == "0000") {
        final rawData = resultList['data'];
        if (rawData is! Map<String, dynamic>) {
          Logger().e('kidokChartService: data 필드 타입 오류');
          return;
        }
        final KidokChartData kidokChartData = KidokChartData.fromJson(rawData);
        kidokChartController.setKidokChartData(kidokChartData);
      } else if (resultValue == "9999") {
        kidokChartController.setEmpty();
      } else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '학습 데이터가 없습니다.',
          onTap: () => Get.back(),
          buttonText: '확인',
        );
      }
    }
  } catch (e) {
    Logger().e('Unexpected error: $e');
  } finally {
    kidokChartController.isLoading.value = false;
  }
}
