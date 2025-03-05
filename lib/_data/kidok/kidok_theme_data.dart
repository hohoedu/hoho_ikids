import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/color_parse.dart';
import 'package:hani_booki/utils/text_format.dart';

class KidokThemeData {
  final String subject;
  final int kidokColor;
  final int subjectColor;
  final int boxColor;
  final int textColor;
  final int goalTextColor;
  final String goal;

  KidokThemeData({
    required this.subject,
    required this.kidokColor,
    required this.subjectColor,
    required this.boxColor,
    required this.textColor,
    required this.goalTextColor,
    required this.goal,
  });

  factory KidokThemeData.fromJson(Map<String, dynamic> json) {
    return KidokThemeData(
        subject: json['subject'] ?? '',
        kidokColor: int.parse(removeTwoChars(json['bgcolor']), radix: 16),
        subjectColor:
            int.parse(removeTwoChars(json['subject_bgcolor']), radix: 16),
        boxColor: int.parse(removeTwoChars(json['left_bgcolor']), radix: 16),
        textColor:
            int.parse(removeTwoChars(json['left_top_text_color']), radix: 16),
        goalTextColor: int.parse(
            removeTwoChars(json['left_subject_2_text_color']),
            radix: 16),
        goal: autoWrapText(json['left_subject_2'], 10));
  }
}

class KidokThemeDataController extends GetxController {
  final Rx<KidokThemeData?> _kidokThemeData = Rx<KidokThemeData?>(null);

  void setKidokThemeData(KidokThemeData kidokThemeData) {
    _kidokThemeData.value = kidokThemeData;
  }

  KidokThemeData? get kidokThemeData => _kidokThemeData.value;
}
