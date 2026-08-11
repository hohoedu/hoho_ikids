import 'dart:convert';

import 'package:hani_booki/_core/env.dart';
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
  final String url = Env.get('MISSION_SAVE_URL');
  final userdata = Get.find<UserDataController>();

  // MissionController가 라우트 정리 등으로 사라진 경우 크래시 대신 안전하게 종료
  if (!Get.isRegistered<MissionController>()) {
    Logger().e('missionSaveService: MissionController not registered');
    return MissionResult(success: false, message: '');
  }
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
