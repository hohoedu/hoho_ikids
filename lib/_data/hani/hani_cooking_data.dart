import 'package:get/get.dart';

/// 하니 요리 데이터
class HaniCookingData {
  // TODO: 응답 스펙 나오면 필드로 바꾸기. 지금은 받은 그대로 보관
  final Map<String, dynamic> raw;

  HaniCookingData({required this.raw});

  HaniCookingData.fromJson(Map<String, dynamic> json) : raw = json;
}

class HaniCookingDataController extends GetxController {
  List<HaniCookingData> _haniCookingDataList = <HaniCookingData>[].obs;

  void setHaniCookingDataList(List<HaniCookingData> haniCookingDataList) {
    _haniCookingDataList = List.from(haniCookingDataList);
    update();
  }

  List<HaniCookingData> get haniCookingDataList => _haniCookingDataList;
}
