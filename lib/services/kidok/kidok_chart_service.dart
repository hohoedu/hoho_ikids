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

  final Map<String, dynamic> requestData = {
    'id': userData.userData?.id ?? '',
    'yy': userData.userData?.year ?? '',
    'hosu': hosu,
    'keycode': keyCode,
  };


  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = response.data;
      final String resultValue = resultList['result'] ?? '';

      if (resultValue == "0000") {
        final KidokChartData kidokChartData = KidokChartData.fromJson(resultList['data']);
        kidokChartController.setKidokChartData(kidokChartData);
        Logger().d(kidokChartData);
      } else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '데이터가 없습니다.',
          onTap: () => Get.back(),
          buttonText: '확인',
        );
      }
    }
  } catch (e) {
    Logger().e('Unexpected error: $e');
  }
}
