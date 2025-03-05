import 'package:get/get.dart';

class HaniEraseData {
  final String imagePath;
  final String voicePath;

  HaniEraseData({
    required this.imagePath,
    required this.voicePath,
  });

  factory HaniEraseData.fromJson(Map<String, dynamic> json) {
   json['imgpath'];

    return HaniEraseData(
      imagePath: json['imgpath'],
      voicePath: json['voice'],
    );
  }
  @override
  String toString() {
    return imagePath;
  }
}

class HaniEraseDataController extends GetxController {

  List<HaniEraseData> _haniEraseDataList = <HaniEraseData>[].obs;

  void setHaniEraseDataList(List<HaniEraseData> haniEraseDataList) {
    _haniEraseDataList = List.from(haniEraseDataList);
    update();
  }

  List<HaniEraseData> get haniEraseDataList => _haniEraseDataList;

  List<List<HaniEraseData>> getGroupedData() {
    List<List<HaniEraseData>> groupedData = [];

    for (int i = 1; i <= 8; i++) {
      List<HaniEraseData> group = _haniEraseDataList
          .where((item) => item.imagePath.contains("Clean${i}_"))
          .toList();
      if (group.isNotEmpty) {
        groupedData.add(group);
      }
    }

    return groupedData;
  }
}
