import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class HaniRecordTenacityData {
  final String personalityTopic;
  final String imagePath;
  final String title;
  final String note;
  final String monthPromise;
  final String insungTitle1;
  final String insungTitle2;
  final String insungTitle3;
  final String insungTitle4;
  final bool isInsung1;
  final bool isInsung2;
  final bool isInsung3;
  final bool isInsung4;

  HaniRecordTenacityData({
    required this.personalityTopic,
    required this.imagePath,
    required this.title,
    required this.note,
    required this.monthPromise,
    required this.insungTitle1,
    required this.insungTitle2,
    required this.insungTitle3,
    required this.insungTitle4,
    required this.isInsung1,
    required this.isInsung2,
    required this.isInsung3,
    required this.isInsung4,
  });

  HaniRecordTenacityData.fromJson(Map<String, dynamic> json)
      : personalityTopic = json['personalityTopic'] ?? '',
        imagePath = json['pathimg'] ?? '',
        title = json['title'] ?? '',
        note = json['note'] ?? '',
        monthPromise = json['PromiseMonth'] ?? '',
        insungTitle1 = json['insungtitle_01'] ?? '',
        insungTitle2 = json['insungtitle_02'] ?? '',
        insungTitle3 = json['insungtitle_03'] ?? '',
        insungTitle4 = json['insungtitle_04'] ?? '',
        isInsung1 = json['insung_01'] == 'Y' ? true : false,
        isInsung2 = json['insung_02'] == 'Y' ? true : false,
        isInsung3 = json['insung_03'] == 'Y' ? true : false,
        isInsung4 = json['insung_04'] == 'Y' ? true : false;
}

class HaniRecordTenacityDataController extends GetxController {
  final Rx<HaniRecordTenacityData?> _recordTenacityData = Rx<HaniRecordTenacityData?>(null);

  void setHaniRecordTenacityData(HaniRecordTenacityData recordTenacityData) {
    _recordTenacityData.value = recordTenacityData;
    update();
  }

  void clearData() {
    _recordTenacityData.value = null;
    update();
  }

  HaniRecordTenacityData? get recordTenacityData => _recordTenacityData.value;
}
