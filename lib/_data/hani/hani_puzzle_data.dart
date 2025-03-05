import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HaniPuzzleData {
  final String form;
  final String sound;
  final String mean;
  final String voicePath;
  final String backImage;

  HaniPuzzleData({
    required this.form,
    required this.sound,
    required this.mean,
    required this.voicePath,
    required this.backImage,
  });

  factory HaniPuzzleData.fromJson(List<Map<String, dynamic>> jsonList) {
    String form = '';
    String sound = '';
    String mean = '';
    String voicePath = '';
    String backImage = '';

    for (var json in jsonList) {
      String path = json['imgpath'];
      if (path.endsWith('1.png')) {
        form = path;
      } else if (path.endsWith('2.png')) {
        sound = path;
      } else if (path.endsWith('3.png')) {
        mean = path;
      }
      voicePath = json['voicepath'];
      backImage = json['bgimg'];
    }

    return HaniPuzzleData(
      form: form,
      sound: sound,
      mean: mean,
      voicePath: voicePath,
      backImage: backImage,
    );
  }

}
class HaniPuzzleDataController extends GetxController {
  List<HaniPuzzleData> _haniPuzzleDataList = <HaniPuzzleData>[].obs;

  void setHaniPuzzleDataList(List<HaniPuzzleData> haniPuzzleDataList) {
    _haniPuzzleDataList = List.from(haniPuzzleDataList);
    update();
  }

  List<HaniPuzzleData> get haniPuzzleDataList => _haniPuzzleDataList;
}
