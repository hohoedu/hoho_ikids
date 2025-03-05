import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/color_parse.dart';

class BookiHomeData {
  final String category;
  final String imagePath;

  BookiHomeData({
    required this.category,
    required this.imagePath,
  });

  BookiHomeData.fromJson(Map<String, dynamic> json)
      : category = json['gb'],
        imagePath = json['img'];
}

class BookiHomeDataController extends GetxController {
  Map<String, String> _bookiHomeData = {};
  List<BookiHomeData> _bookiHomeDataList = [];

  void setBookiHomeDataMap(List<dynamic> jsonData) {
    _bookiHomeData = {for (var item in jsonData) item['gb']: item['img']};
    _bookiHomeDataList =
        jsonData.map((item) => BookiHomeData.fromJson(item)).toList();
    update();
  }

  Map<String, String> get bookiHomeData => _bookiHomeData;

  List<BookiHomeData> get bookiHomeDataList => _bookiHomeDataList;
}
