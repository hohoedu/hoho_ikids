import 'package:get/get.dart';

class HaniRotateData {
  final String frontImage;
  final String backImage;
  final String sound;

  HaniRotateData({
    required this.frontImage,
    required this.backImage,
    required this.sound,
  });

  HaniRotateData.fromJson(Map<String, dynamic> json)
      : frontImage = json["front_imgpath"],
        backImage = json["back_imgpath"],
        sound = json["voice"];
}

class HaniRotateDataController extends GetxController {
  List<HaniRotateData> _rotateDataList = <HaniRotateData>[].obs;

  void setRotateDataList(List<HaniRotateData> rotateDataList) {
    _rotateDataList = rotateDataList;
    update();
  }

  List<HaniRotateData> get rotateDataList => _rotateDataList;
}
