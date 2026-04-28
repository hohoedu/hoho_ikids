import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:logger/logger.dart';

Future<void> missionListService(String keycode,) async {
  final String url = dotenv.get('MISSION_LIST_URL');
  final userdata = Get.find<UserDataController>();
  final controller = Get.find<MissionController>();

  final Map<String, dynamic> requestData = {
    'id': userdata.userData!.id,
    'yy': userdata.userData!.year,
    'schoolid': userdata.userData!.schoolId,
    'keycode':keycode,
  };

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['result'] == '0000') {
        final data = MissionData.fromJson(result);
        controller.setMissionData(data);
      }
    }
  } catch (e) {
    Logger().d('missionListService error = $e');
  }
}