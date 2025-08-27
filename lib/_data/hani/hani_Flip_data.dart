import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HaniFlipData {
  final String frontImagePath;
  final String backImagePath;
  final String frontVoicePath;
  final String backVoicePath;

  HaniFlipData({
    required this.frontImagePath,
    required this.backImagePath,
    required this.frontVoicePath,
    required this.backVoicePath,
  });

  factory HaniFlipData.fromJson(Map<String, dynamic> json) {
    String frontImagePath = json['imgpath'];
    String backImagePath = frontImagePath.replaceFirst(RegExp(r'/f_card_'), '/b_card_');
    String frontVoicePath = json['voicepath'];
    String backVoicePath = frontVoicePath.replaceFirst(".mp3", "_2.mp3");
    Logger().d('frontVoice $frontVoicePath');
    Logger().d('backVoice $backVoicePath');

    return HaniFlipData(
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
        frontVoicePath: frontVoicePath,
        backVoicePath: backVoicePath);
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
