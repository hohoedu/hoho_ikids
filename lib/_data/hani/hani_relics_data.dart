import 'package:get/get.dart';

/// 하니 유물찾기 데이터
class HaniRelicsData {
  // TODO: 응답 스펙 나오면 필드로 바꾸기. 지금은 받은 그대로 보관
  final Map<String, dynamic> raw;

  HaniRelicsData({required this.raw});

  HaniRelicsData.fromJson(Map<String, dynamic> json) : raw = json;
}

class HaniRelicsDataController extends GetxController {
  List<HaniRelicsData> _haniRelicsDataList = <HaniRelicsData>[].obs;

  void setHaniRelicsDataList(List<HaniRelicsData> haniRelicsDataList) {
    _haniRelicsDataList = List.from(haniRelicsDataList);
    update();
  }

  List<HaniRelicsData> get haniRelicsDataList => _haniRelicsDataList;
}
