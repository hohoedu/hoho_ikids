import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:logger/logger.dart';

Future<void> starSaveService({required String btype, required String hosu, required String gb, required String keycode}) async {
  final String url = dotenv.get('FIND_STAR_SAVE_URL');
  final userdata = Get.find<UserDataController>();

  final Map<String, dynamic> requestData = {
    'id': userdata.userData!.id,
    'yy': userdata.userData!.year,
    'btype': btype,
    'hosu': hosu,
    'gb': gb,
  };

  Logger().d("requestData = $requestData");
  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);

      if (result['result'] == '0000') {
        totalStarService(keycode);
      }
    }
  } catch (e) {
    Logger().d('setStarSaveService error = $e');
  }
  return null;
}
