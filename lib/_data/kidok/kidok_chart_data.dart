import 'package:get/get.dart';

class KidokChartData {
  final String understanding;
  final String emotion;
  final String expression;
  final String vocabulary;
  final String knowledge;
  final String thought;


  KidokChartData({
    required this.understanding,
    required this.emotion,
    required this.expression,
    required this.vocabulary,
    required this.knowledge,
    required this.thought,
  });

  KidokChartData.fromJson(Map<String, dynamic> json)
      : understanding = json['understanding'],
        emotion = json['emotion'],
        expression = json['expression'],
        vocabulary = json['vocabulary'],
        knowledge = json['knowledge'],
        thought = json['thought'];
}

class KidokChartDataController extends GetxController {
  final RxList<KidokChartData> _kidokChartDataList = <KidokChartData>[].obs;

  List<KidokChartData> get kidokChartDataList => _kidokChartDataList;

  void setKidokChartDataList(List<KidokChartData> kidokChartDataList) {
    _kidokChartDataList.assignAll(kidokChartDataList);
  }

  void setKidokChartData(KidokChartData data) {
    _kidokChartDataList.add(data);
  }

  void setKidokChartDataFromJson(Map<String, dynamic> json) {
    if (json.containsKey('data')) {
      final data = KidokChartData.fromJson(json['data']);
      _kidokChartDataList.add(data);
    }
  }
}
