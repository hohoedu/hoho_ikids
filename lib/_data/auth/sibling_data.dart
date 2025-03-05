import 'package:get/get.dart';

class SiblingData {
  final String id;
  final String username;
  final String schoolId;
  final String schoolName;

  SiblingData({
    required this.id,
    required this.username,
    required this.schoolId,
    required this.schoolName,
  });

  SiblingData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['cname'],
        schoolId = json['school_id'],
        schoolName = json['schoolname'] ?? '';
}

class SiblingDataController extends GetxController {
  List<SiblingData> _siblingDataList = <SiblingData>[].obs;

  void setSiblingDataList(List<SiblingData> siblingDataList) {
    _siblingDataList = List.from(siblingDataList);
    update();
  }

  List<SiblingData> get siblingDataList => _siblingDataList;
}
