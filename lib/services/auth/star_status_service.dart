import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:logger/logger.dart';

Future<Map<String, dynamic>?> starStatusService({required String btype, required String hosu, required String gb}) async {
  final String url = dotenv.get('FIND_STAR_STATE_URL');
  final userdata = Get.find<UserDataController>();

  final Map<String, dynamic> requestData = {
    'id': userdata.userData!.id,
    'yy': userdata.userData!.year,
    'btype': btype,
    'hosu': hosu,
    'gb': gb,
  };

  Logger().d('requestData = $requestData');
  try {
    final response = await dio.post(url, data: jsonEncode(requestData));
Logger().d(response);
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);

      if (result['result'] == '0000') {
        return result;
      }
    }
  } catch (e) {
    Logger().d('getStarStatusService error = $e');
  }
  return null;
}
