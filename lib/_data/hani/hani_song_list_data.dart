import 'package:get/get.dart';

class HaniSongListData {
  final String imagePath;
  final String category;

  HaniSongListData({
    required this.imagePath,
    required this.category,
  });

  HaniSongListData.fromJson(Map<String, dynamic> json)
      : imagePath = json['imgpath'],
        category = json['hosu'];
}

class HaniSongListController extends GetxController {
  List<HaniSongListData> _haniSongList = <HaniSongListData>[].obs;

  void setHaniSongList(List<HaniSongListData> haniSongList) {
    _haniSongList = List.from(haniSongList);
    update();
  }

  List<HaniSongListData> get haniSongList => _haniSongList;
}
