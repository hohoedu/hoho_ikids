import 'package:get/get.dart';

class HaniMakeCardData {
  final String first;
  final String second;
  final String correct;
  final String wrong;

  HaniMakeCardData({
    required this.first,
    required this.second,
    required this.correct,
    required this.wrong,
  });

  HaniMakeCardData.fromJson(Map<String, dynamic> json)
      : first = json["first"],
        second = json["second"],
        correct = json["correct"],
        wrong = json["wrong"];
}

class HaniMakeCardDataController extends GetxController {
  List<HaniMakeCardData> _makeCardDataList = <HaniMakeCardData>[].obs;

  void setMakeCardDataList(List<HaniMakeCardData> makeCardDataList) {
    _makeCardDataList = makeCardDataList;
    update();
  }

  List<HaniMakeCardData> get makeCardDataList => _makeCardDataList;
}
