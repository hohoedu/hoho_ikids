import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/color_parse.dart';

class HaniHomData {
  final String category;
  final String imagePath;

  HaniHomData({
    required this.category,
    required this.imagePath,
  });

  HaniHomData.fromJson(Map<String, dynamic> json)
      : category = json['gb'],
        imagePath = json['img'];
}

class HaniHomeDataController extends GetxController {
  Map<String, String> _haniHomeData = {};
  List<HaniHomData> _haniHomeDataList = [];

  void setHaniHomeDataMap(List<dynamic> jsonData) {
    _haniHomeData = {for (var item in jsonData) item['gb']: item['img']};
    _haniHomeDataList =
        jsonData.map((item) => HaniHomData.fromJson(item)).toList();
    update();
  }

  Map<String, String> get haniHomeData => _haniHomeData;

  List<HaniHomData> get haniHomeDataList => _haniHomeDataList;
}
