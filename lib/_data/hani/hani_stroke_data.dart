import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HaniStrokeData {
  final String meaning;
  final String phonetic;
  final String imagePath;
  final String voicePath;

  HaniStrokeData({
    required this.meaning,
    required this.phonetic,
    required this.imagePath,
    required this.voicePath,
  });

  factory HaniStrokeData.fromJson(Map<String, dynamic> json) {
    String hanja = json['note'];
    String meaning = hanja.substring(0, hanja.length - 1);
    String phonetic = hanja.substring(hanja.length - 1);

    return HaniStrokeData(
      meaning: meaning,
      phonetic: phonetic,
      imagePath: json['imgpath'],
      voicePath: json['voice']
    );
  }
}

class HaniStrokeDataController extends GetxController {
  List<HaniStrokeData> _haniStrokeDataList = <HaniStrokeData>[].obs;

  void setHaniStrokeDataList(List<HaniStrokeData> haniStrokeDataList) {
    _haniStrokeDataList = List.from(haniStrokeDataList);
    update();
  }

  List<HaniStrokeData> get haniStrokeDataList => _haniStrokeDataList;
}
