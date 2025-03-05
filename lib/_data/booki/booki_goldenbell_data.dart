import 'package:get/get.dart';

class BookiGoldenbellData {
  final List<String> questions;
  final List<String> answer_1;
  final List<String> answer_2;
  final List<String> answer_3;
  final List<String> voicePath;
  final List<String> correctAnswer;

  BookiGoldenbellData({
    required this.questions,
    required this.answer_1,
    required this.answer_2,
    required this.answer_3,
    required this.voicePath,
    required this.correctAnswer,
  });

  factory BookiGoldenbellData.fromJson(Map<String, dynamic> json) {
    String imgPath = json['imgpath'];
    String voicePath = json['voicepath'];

    List<String> correctAnswers = json.keys
        .where((key) => key.startsWith('goldenbell_')) // goldenbell_ 키 필터링
        .map((key) => json[key] as String) // 값 추출
        .toList();

    int questionCount = json.keys.where((key) => key.startsWith('goldenbell_')).length;

    List<String> questions = [];
    List<String> answer_1 = [];
    List<String> answer_2 = [];
    List<String> answer_3 = [];
    List<String> voicePaths = [];

    for (int i = 1; i <= questionCount; i++) {
      questions.add('${imgPath}q$i.png');
      answer_1.add('${imgPath}q$i-1.png');
      answer_2.add('${imgPath}q$i-2.png');
      answer_3.add('${imgPath}q$i-3.png');
      voicePaths.add('${voicePath}voice$i.mp3');
    }

    return BookiGoldenbellData(
      questions: questions,
      answer_1: answer_1,
      answer_2: answer_2,
      answer_3: answer_3,
      voicePath: voicePaths,
      correctAnswer: correctAnswers
    );
  }
}

class BookiGoldenbellDataController extends GetxController {
  List<BookiGoldenbellData> _bookiGoldenbellDataList =
      <BookiGoldenbellData>[].obs;

  void setBookiGoldenbellDataList(
      List<BookiGoldenbellData> bookiGoldenbellDataList) {
    _bookiGoldenbellDataList = List.from(bookiGoldenbellDataList);
    update();
  }

  List<BookiGoldenbellData> get bookiGoldenbellDataList =>
      _bookiGoldenbellDataList;
}
