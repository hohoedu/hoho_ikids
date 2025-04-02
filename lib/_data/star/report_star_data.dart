import 'package:get/get.dart';

class ReportStarData {
  final String star;

  ReportStarData({
    required this.star,
  });

  ReportStarData.fromJson(Map<String, dynamic> json) : star = json['total_star'];
}

class ReportStarDataController extends GetxController {
  RxString totalStar = "".obs;

  void setTotalStar(String star) {
    totalStar.value = star;
  }
}