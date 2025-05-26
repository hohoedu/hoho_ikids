import 'package:get/get.dart';

class HaniMakeCardData {
  final String first;
  final String second;
  final String correct;
  final String wrong;
  final String clear;
  final String title;

  HaniMakeCardData({
    required this.first,
    required this.second,
    required this.correct,
    required this.wrong,
    required this.clear,
    required this.title,
  });

  HaniMakeCardData.fromJson(Map<String, dynamic> json)
      : first = json["first"],
        second = json["second"],
        correct = json["correct"],
        wrong = json["wrong"],
        clear = json["over"],
        title = json["title"];
}

class HaniMakeCardDataController extends GetxController {
  List<HaniMakeCardData> _makeCardDataList = <HaniMakeCardData>[].obs;

  void setMakeCardDataList(List<HaniMakeCardData> makeCardDataList) {
    if (_makeCardDataList.isEmpty) {
      _makeCardDataList = makeCardDataList;
    } else {
      _makeCardDataList.clear(); // 이미 데이터가 있을 경우, 기존 데이터를 지우고 새로 저장
      _makeCardDataList.addAll(makeCardDataList);
    }
    update(); // 데이터 변경 후 UI 업데이트
  }

  List<HaniMakeCardData> get makeCardDataList => _makeCardDataList;
}
