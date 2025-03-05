import 'package:get/get.dart';

class StarData {
  final String star;

  StarData({
    required this.star,
  });

  StarData.fromJson(Map<String, dynamic> json) : star = json['total_star'];
}

class StarDataController extends GetxController {
  RxString totalStar = "".obs;

  void setTotalStar(String star) {
    totalStar.value = star;
  }
}