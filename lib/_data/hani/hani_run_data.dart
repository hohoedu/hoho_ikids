import 'package:get/get.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_data.dart';

/// 하니런 동전 한자 하나 (서버 응답 data 의 항목)
class HaniRunData {
  final String no; // 동전 이미지 번호. 예: y01 → coin-y01.png
  final String text; // 말풍선 훈음. 예: 불 화

  HaniRunData({required this.no, required this.text});

  HaniRunData.fromJson(Map<String, dynamic> json)
      : no = json['no'],
        text = json['text'];

  Hanja toHanja() => Hanja(no, text);
}

class HaniRunDataController extends GetxController {
  List<HaniRunData> _haniRunDataList = <HaniRunData>[].obs;

  void setHaniRunDataList(List<HaniRunData> haniRunDataList) {
    _haniRunDataList = List.from(haniRunDataList);
    update();
  }

  List<HaniRunData> get haniRunDataList => _haniRunDataList;
}
