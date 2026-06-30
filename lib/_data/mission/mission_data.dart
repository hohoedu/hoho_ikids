import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MissionInfo {
  final String missionNumber;
  final String missionName;
  final int totalCount;
  final int currentCount;
  final String missionStar;
  final String missionType;
  final String expiration;
  final String gamok;
  final String isCleared;

  MissionInfo({
    required this.missionNumber,
    required this.missionName,
    required this.totalCount,
    required this.currentCount,
    required this.missionStar,
    required this.missionType,
    required this.expiration,
    required this.gamok,
    required this.isCleared,
  });

  factory MissionInfo.fromJson(Map<String, dynamic> json) {
    return MissionInfo(
      missionNumber: json['missionNum']?.toString() ?? '',
      missionName: json['note'] ?? '',
      totalCount: int.tryParse(json['max_limit'].toString()) ?? 0,
      currentCount: int.tryParse(json['current_cnt'].toString()) ?? 0,
      missionStar: json['missionstar']?.toString() ?? '0',
      missionType: json['gb'] ?? '',
      expiration: json['expiration'] ?? '',
      gamok: json['gamok'] ?? '',
      isCleared: json['is_cleared'] ?? '',
    );
  }

  double get progress => totalCount == 0 ? 0 : (currentCount / totalCount).clamp(0.0, 1.0);

  bool get isCompleted => currentCount >= totalCount;

  MissionInfo copyWith({int? currentCount}) {
    return MissionInfo(
      missionNumber: missionNumber,
      missionName: missionName,
      totalCount: totalCount,
      currentCount: currentCount ?? this.currentCount,
      missionStar: missionStar,
      missionType: missionType,
      expiration: expiration,
      gamok: gamok,
      isCleared: isCleared,
    );
  }
}

class MissionData {
  final String expiredAt;
  final MissionInfo attendanceMission;
  final MissionInfo contentMission;

  MissionData({
    required this.expiredAt,
    required this.attendanceMission,
    required this.contentMission,
  });

  factory MissionData.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'];
    final list = (rawList as List<dynamic>? ?? []).map((e) => MissionInfo.fromJson(e as Map<String, dynamic>)).toList();

    final emptyMission = (String type) => MissionInfo(
          missionNumber: '',
          missionName: '미션 없음',
          totalCount: 0,
          currentCount: 0,
          missionStar: '0',
          missionType: type,
          expiration: '',
          gamok: '',
          isCleared: '',
        );

    final attendance = list.firstWhere(
      (m) => m.missionType == 'attendance',
      orElse: () => emptyMission('attendance'),
    );

    final content = list.firstWhere(
      (m) => m.missionType != 'attendance',
      orElse: () => emptyMission('content'),
    );

    final expiredAt = json['expiredAt'] ?? attendance.expiration;

    return MissionData(
      expiredAt: expiredAt,
      attendanceMission: attendance,
      contentMission: content,
    );
  }
}

class MissionController extends GetxController {
  final Rx<MissionData?> missionData = Rx<MissionData?>(null);
  final RxBool attendanceCleared = false.obs;
  final RxBool contentCleared = false.obs;

  void markCleared(int missionNum) {
    if (missionNum == 1) {
      attendanceCleared.value = true;
    } else {
      contentCleared.value = true;
    }
  }

  void setMissionData(MissionData data) {
    missionData.value = data;
    attendanceCleared.value = data.attendanceMission.isCleared == 'Y';
    contentCleared.value = data.contentMission.isCleared == 'Y';
  }

  MissionInfo? get attendanceMission => missionData.value?.attendanceMission;

  MissionInfo? get contentMission => missionData.value?.contentMission;

  void reset() {
    missionData.value = null;
    attendanceCleared.value = false;
    contentCleared.value = false;
  }

  void updateAttendanceProgress(int newCount) {
    final current = missionData.value;
    if (current == null) return;
    missionData.value = MissionData(
      expiredAt: current.expiredAt,
      attendanceMission: current.attendanceMission.copyWith(currentCount: newCount),
      contentMission: current.contentMission,
    );
    missionData.refresh();
  }

  void updateContentProgress(int newCount) {
    final current = missionData.value;
    if (current == null) return;
    missionData.value = MissionData(
      expiredAt: current.expiredAt,
      attendanceMission: current.attendanceMission,
      contentMission: current.contentMission.copyWith(currentCount: newCount),
    );
    missionData.refresh();
  }
}
