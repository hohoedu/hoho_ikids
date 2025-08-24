import 'package:get/get.dart';

class HaniMakeWordData {
  final String first;
  final String second;
  final String correct;
  final String wrong1;
  final String wrong2;
  final String wrong3;
  final String clear;
  final String title;
  final String voice;

  HaniMakeWordData({
    required this.first,
    required this.second,
    required this.correct,
    required this.wrong1,
    required this.wrong2,
    required this.wrong3,
    required this.clear,
    required this.title,
    required this.voice,
  });

  HaniMakeWordData.fromJson(Map<String, dynamic> json)
      : first = json["first"],
        second = json["second"],
        correct = json["correct"],
        wrong1 = json["wrong1"],
        wrong2 = json["wrong2"],
        wrong3 = json["wrong3"],
        clear = json["over"],
        title = json["title"],
        voice = json["voice"] ?? "";
}

class HaniMakeWordDataController extends GetxController {
  List<HaniMakeWordData> _makeWordDataList = <HaniMakeWordData>[].obs;

  void setMakeWordDataList(List<HaniMakeWordData> makeWordDataList) {
    if (_makeWordDataList.isEmpty) {
      _makeWordDataList = makeWordDataList;
    } else {
      _makeWordDataList.clear(); // 이미 데이터가 있을 경우, 기존 데이터를 지우고 새로 저장
      _makeWordDataList.addAll(makeWordDataList);
    }
    update(); // 데이터 변경 후 UI 업데이트
  }

  List<HaniMakeWordData> get makeWordDataList => _makeWordDataList;
}
