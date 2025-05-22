import 'package:get/get.dart';

class HaniGoldenbellSuData {
  final String question;
  final String answer_1;
  final String answer_2;
  final String answer_3;
  final String voicePath;
  final String correctAnswer;

  HaniGoldenbellSuData({
    required this.question,
    required this.answer_1,
    required this.answer_2,
    required this.answer_3,
    required this.voicePath,
    required this.correctAnswer,
  });

  factory HaniGoldenbellSuData.fromJson(Map<String, dynamic> json) {
    String question = json['q'];
    String answer_1 = json['e1'];
    String answer_2 = json['e2'];
    String answer_3 = json['e3'];
    String a1 = json['a1'];
    String a2 = json['a2'];
    String a3 = json['a3'];
    String voicePath = json['voice'];

    String correctAnswers;

    if (a1 == "o") {
      correctAnswers = '1';
    } else if (a2 == "o") {
      correctAnswers = '2';
    } else if (a3 == "o") {
      correctAnswers = '3';
    } else {
      throw Exception("No correct answer marked as 'O'");
    }

    return HaniGoldenbellSuData(
        question: question,
        answer_1: answer_1,
        answer_2: answer_2,
        answer_3: answer_3,
        voicePath: voicePath,
        correctAnswer: correctAnswers);
  }
}

class HaniGoldenbellSuDataController extends GetxController {
  List<HaniGoldenbellSuData> _haniGoldenbellDataList = <HaniGoldenbellSuData>[].obs;

  void setHaniGoldenbellSuDataList(List<HaniGoldenbellSuData> haniGoldenbellDataList) {
    _haniGoldenbellDataList = List.from(haniGoldenbellDataList);
    update();
  }

  List<HaniGoldenbellSuData> get haniGoldenbellDataList => _haniGoldenbellDataList;
}
