import 'package:get/get.dart';

class HaniInsungListData {
  final String imagePath;
  final String category;

  HaniInsungListData({
    required this.imagePath,
    required this.category,
  });

  HaniInsungListData.fromJson(Map<String, dynamic> json)
      : imagePath = json['imgpath'],
        category = json['hosu'];
}

class HaniInsungListController extends GetxController {
  List<HaniInsungListData> _haniInsungList = <HaniInsungListData>[].obs;

  void setHaniInsungsList(List<HaniInsungListData> haniInsungList) {
    _haniInsungList = List.from(haniInsungList);
    update();
  }

  List<HaniInsungListData> get haniInsungList => _haniInsungList;
}
