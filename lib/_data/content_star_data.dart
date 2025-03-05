import 'package:get/get.dart';

class ContentStarData {
  final String category;
  final String starCount;

  ContentStarData({
    required this.category,
    required this.starCount,
  });

  ContentStarData.fromJson(Map<String, dynamic> json)
      : category = json['gb'],
        starCount = json['img'];
}

class ContentStarDataController extends GetxController {
  List<ContentStarData> _contentStarDataList = <ContentStarData>[].obs;

  void setContentStarDataList(List<dynamic> contentStarDataList) {
    _contentStarDataList = List.from(contentStarDataList);
    update();
  }

  List<ContentStarData> get contentStarDataList => _contentStarDataList;
}
