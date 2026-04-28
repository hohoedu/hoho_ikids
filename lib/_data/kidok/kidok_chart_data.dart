import 'package:get/get.dart';

class TopItem {
  final String type;
  final String text;
  final String rate;

  TopItem({required this.type, required this.text, required this.rate});

  TopItem.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? '',
        text = json['text'] ?? '',
        rate = json['rate'] ?? '0';

  // top1/2/3 키가 없을 때 사용할 빈 인스턴스
  TopItem.empty()
      : type = '',
        text = '',
        rate = '0';
}

class HosuBook {
  final String hosu;
  final int count;

  HosuBook({required this.hosu, required this.count});

  HosuBook.fromJson(Map<String, dynamic> json)
      : hosu = json['hosu'],
        count = json['count'];
}

class KidokChartData {
  final double understanding;
  final double emotion;
  final double expression;
  final double vocabulary;
  final double knowledge;
  final double thought;
  final TopItem top1;
  final TopItem top2;
  final TopItem top3;
  final List<HosuBook> hosuBooks;

  KidokChartData({
    required this.understanding,
    required this.emotion,
    required this.expression,
    required this.vocabulary,
    required this.knowledge,
    required this.thought,
    required this.top1,
    required this.top2,
    required this.top3,
    required this.hosuBooks,
  });

  KidokChartData.fromJson(Map<String, dynamic> json)
      : understanding = parsePercent(json['understanding']),
        emotion = parsePercent(json['emotion']),
        expression = parsePercent(json['expression']),
        vocabulary = parsePercent(json['vocabulary']),
        knowledge = parsePercent(json['knowledge']),
        thought = parsePercent(json['thought']),
        // top1/2/3 키가 없을 경우 빈 TopItem으로 대체
        top1 = json['top1'] != null ? TopItem.fromJson(json['top1']) : TopItem.empty(),
        top2 = json['top2'] != null ? TopItem.fromJson(json['top2']) : TopItem.empty(),
        top3 = json['top3'] != null ? TopItem.fromJson(json['top3']) : TopItem.empty(),
        hosuBooks = (json['hosuBooks'] as List?)?.map((e) => HosuBook.fromJson(e)).toList() ?? [];
}

// null·빈 문자열·%없는 값 모두 안전하게 파싱, 실패 시 0.0 반환
double parsePercent(dynamic value) {
  if (value == null) return 0.0;
  try {
    return double.parse(value.toString().replaceAll('%', '').trim());
  } catch (_) {
    return 0.0;
  }
}


class KidokChartDataController extends GetxController {
  final RxList<KidokChartData> _kidokChartDataList = <KidokChartData>[].obs;
  final RxBool isEmpty = false.obs;
  final isLoading = true.obs;
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
  void setEmpty() {
    _kidokChartDataList.clear();
    isEmpty.value = true;
  }

  // 조회 전 이전 데이터 초기화 (재진입 시 누적 방지)
  void clearList() {
    _kidokChartDataList.clear();
    isEmpty.value = false;
  }
}
