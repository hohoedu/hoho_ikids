import 'package:get/get.dart';

class HaniFlipData {
  final String frontImagePath;
  final String backImagePath;
  final String voicePath;

  HaniFlipData({
    required this.frontImagePath,
    required this.backImagePath,
    required this.voicePath,
  });

  factory HaniFlipData.fromJson(Map<String, dynamic> json) {
    String frontImagePath = json['imgpath'];
    String backImagePath =
        frontImagePath.replaceFirst(RegExp(r'/f_card_'), '/b_card_');
    String voicePath = json['voicepath'];

    return HaniFlipData(
      frontImagePath: frontImagePath,
      backImagePath: backImagePath,
      voicePath: voicePath,
    );
  }
}

class HaniFlipDataController extends GetxController {
  List<HaniFlipData> _haniFlipDataList = <HaniFlipData>[].obs;

  void setHaniFlipDataList(List<HaniFlipData> haniFlipDataList) {
    _haniFlipDataList = List.from(haniFlipDataList);
    update();
  }

  List<HaniFlipData> get haniFlipDataList => _haniFlipDataList;
}
