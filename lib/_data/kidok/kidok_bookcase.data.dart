import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/color_parse.dart';
import 'package:hani_booki/utils/text_format.dart';

class KidokBookcaseData {
  final String volume;
  final String note;
  final String subject;
  final int subjectColor;
  final int boxColor;

  KidokBookcaseData({
    required this.volume,
    required this.note,
    required this.subject,
    required this.subjectColor,
    required this.boxColor,
  });

  KidokBookcaseData.fromJson(Map<String, dynamic> json)
      : volume = json['hosu'],
        note = json['note'],
        subject = json['subject'],
        subjectColor = int.parse(removeTwoChars(json['subject_bgcolor']), radix: 16),
        boxColor = int.parse(removeTwoChars(json['left_bgcolor']), radix: 16);
}

class KidokBookcaseDataController extends GetxController {
  List<KidokBookcaseData> _kidokBookcaseDataList = <KidokBookcaseData>[].obs;

  void setKidokBookcaseDataList(List<KidokBookcaseData> kidokBookcaseDataList) {
    _kidokBookcaseDataList = List.from(kidokBookcaseDataList);
    update();
  }

  List<KidokBookcaseData> get kidokBookcaseDataList => _kidokBookcaseDataList;
}
