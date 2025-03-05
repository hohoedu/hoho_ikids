import 'package:get/get.dart';

class KidokSublistData {
  final String bookName;
  final String questionCount;
  final bool isCompleted;

  KidokSublistData({
    required this.bookName,
    required this.questionCount,
    required this.isCompleted,
  });

  KidokSublistData.fromJson(Map<String, dynamic> json)
      : bookName = json['bname'],
        questionCount = json['Num_questions'],
        isCompleted = json['Ok_questions'] != '99';
}

class KidokSublistDataController extends GetxController {
  List<KidokSublistData> _kidokSublistDataList = <KidokSublistData>[].obs;

  void setKidokSubListDataList(List<KidokSublistData> kidokSublistDataList) {
    _kidokSublistDataList = List.from(kidokSublistDataList);
    update();
  }

  List<KidokSublistData> get kidokSublistDataList => _kidokSublistDataList;
}
