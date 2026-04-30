import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:logger/logger.dart';

Future<void> missionClearService(int missionNum, String keycode) async {
  final String url = dotenv.get('MISSION_CLEAR_URL');
  final userdata = Get.find<UserDataController>();
  final missionController = Get.find<MissionController>();

  final mission = missionNum == 1 ? missionController.attendanceMission : missionController.contentMission;
  if (mission == null) return;

  final Map<String, dynamic> requestData = {
    'id': userdata.userData!.id,
    'yy': userdata.userData!.year,
    'gamok': keycode.substring(0, 1),
    'hosu': keycode.substring(2, 4),
    'missionNum': missionNum.toString(),
    'missionstar': mission.missionStar
  };
  Logger().d(requestData);

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));
    Logger().d(response);
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['result'] == '0000') {
        final newCount = int.tryParse(result['current_cnt'].toString()) ?? mission.currentCount + 1;

        if (missionNum == 1) {
          missionController.updateAttendanceProgress(newCount);
        } else {
          missionController.updateContentProgress(newCount);
        }

        missionController.markCleared(missionNum);
      }
    }
  } catch (e) {
    Logger().d('completeMissionService error = $e');
  }
}
