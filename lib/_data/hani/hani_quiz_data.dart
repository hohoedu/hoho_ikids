import 'package:get/get.dart';

class HaniQuizData {
  final String first;
  final String second;
  final String third;
  final String question;
  final String correct;
  final String wrong;
  final String voice;

  HaniQuizData({
    required this.first,
    required this.second,
    required this.third,
    required this.question,
    required this.correct,
    required this.wrong,
    required this.voice,
  });

  HaniQuizData.fromJson(Map<String, dynamic> json)
      : first = json['first'],
        second = json['second'],
        third = json['third'],
        question = json['question'],
        correct = json['correct'],
        wrong = json['wrong'],
        voice = json["voice"];
}

class HaniQuizDataController extends GetxController {
  List<HaniQuizData> _haniQuizDataList = <HaniQuizData>[].obs;

  void setHaniQuizDataList(List<HaniQuizData> haniQuizDataList) {
    _haniQuizDataList = List.from(haniQuizDataList);
    update();
  }

  List<HaniQuizData> get haniQuizDataList => _haniQuizDataList;
}
