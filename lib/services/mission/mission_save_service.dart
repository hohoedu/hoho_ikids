import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/mission/mission_data.dart';
import 'package:logger/logger.dart';

class MissionResult {
  final bool success;
  final String message;

  MissionResult({required this.success, required this.message});
}

Future<MissionResult> missionSaveService({required int missionNum, required String gb, required String keycode}) async {
  final String url = dotenv.get('MISSION_SAVE_URL');
  final userdata = Get.find<UserDataController>();
  final controller = Get.find<MissionController>();

  final mission = missionNum == 1 ? controller.attendanceMission : controller.contentMission;

  if (mission == null || mission.isCompleted) {
    return MissionResult(success: false, message: '');
  }

  if (gb != mission.missionType) {
    return MissionResult(success: false, message: '');
  }

  final Map<String, dynamic> requestData = {
    'id': userdata.userData!.id,
    'yy': userdata.userData!.year,
    'missionNum': missionNum.toString(),
    'gb': gb,
    'keycode': keycode,
  };
  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      final message = result['message'] ?? '';
      if (result['result'] == '0000') {
        final newCount = int.tryParse(result['current_cnt'].toString()) ?? mission.currentCount + 1;
        if (missionNum == 1) {
          controller.updateAttendanceProgress(newCount);
        } else {
          controller.updateContentProgress(newCount);
        }
        return MissionResult(success: true, message: message);
      } else {
        return MissionResult(success: false, message: message);
      }
    }
  } catch (e) {
    Logger().d('completeMissionService error = $e');
  }

  return MissionResult(success: true, message: '오류가 발생했습니다.');
}
