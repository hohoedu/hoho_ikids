import 'package:get/get.dart';

class KidokMainData {
  final String bookCode;
  final String bookImage;

  KidokMainData({
    required this.bookCode,
    required this.bookImage,
  });

  KidokMainData.fromJson(Map<String, dynamic> json)
      : bookCode = json['bcode'],
        bookImage = json['img'];
}

class KidokMainDataController extends GetxController {
  List<KidokMainData> _kidokMainDataList = <KidokMainData>[].obs;

  void setKidokMainDataList(List<KidokMainData> kidokMainDataList) {
    _kidokMainDataList = List.from(kidokMainDataList);
    update();
  }

  List<KidokMainData> get kidokMainDataList => _kidokMainDataList;
}
