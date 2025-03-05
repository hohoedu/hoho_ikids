import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/color_parse.dart';

class KidokQuestionData {
  final String bookCode;
  final int questionNumber;
  final String question;
  final bool isExample;
  final String example;
  final String option1;
  final String option2;
  final String option3;
  final String answer;
  final String sound;

  KidokQuestionData({
    required this.bookCode,
    required this.questionNumber,
    required this.question,
    required this.isExample,
    required this.example,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.answer,
    required this.sound,
  });

  KidokQuestionData.fromJson(Map<String, dynamic> json)
      : bookCode = json['bcode'],
        questionNumber = int.parse(json['qnum']),
        question = json['qmunje'],
        isExample = json['ex'] == 'Y' ? true : false,
        example = json['exstr'],
        option1 = json['b1'],
        option2 = json['b2'],
        option3 = json['b3'],
        answer = json['answer'],
        sound = json['bvoice'];
}

class KidokQuestionDataController extends GetxController {
  final Rx<KidokQuestionData?> _kidokQuestionData = Rx<KidokQuestionData?>(null);

  void setKidokQuestionData(KidokQuestionData kidokQuestionData) {
    _kidokQuestionData.value = kidokQuestionData;
    update();
  }

  KidokQuestionData? get kidokQuestionData => _kidokQuestionData.value;
}
