import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/color_parse.dart';

class BookiHomeData {
  final String category;
  final String imagePath;
  final String lastTime;

  BookiHomeData({
    required this.category,
    required this.imagePath,
    required this.lastTime,
  });

  BookiHomeData.fromJson(Map<String, dynamic> json)
      : category = (json['gb'] as String).trim(),
        imagePath = json['img'],
        lastTime = json['edate'] ?? '';
}

class BookiHomeDataController extends GetxController {
  Map<String, String> _bookiHomeData = {};
  Map<String, String> _bookiLastTimeMap = {};
  List<BookiHomeData> _bookiHomeDataList = [];
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => update());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setBookiHomeDataMap(List<dynamic> jsonData) {
    _bookiHomeData = {for (var item in jsonData) (item['gb'] as String).trim(): item['img']};
    _bookiLastTimeMap = {for (var item in jsonData) (item['gb'] as String).trim(): item['edate'] ?? ''};
    _bookiHomeDataList = jsonData.map((item) => BookiHomeData.fromJson(item)).toList();
    update();
  }

  bool isCooltime(String lastTime, String type) {
    const excludedTypes = ['song', 'story', 'write', 'puz', 'quiz', 'workbook', 'han', 'insung'];
    if (excludedTypes.contains(type)) return false;
    try {
      final last = DateTime(
        int.parse(lastTime.substring(0, 4)),
        int.parse(lastTime.substring(4, 6)),
        int.parse(lastTime.substring(6, 8)),
        int.parse(lastTime.substring(8, 10)),
        int.parse(lastTime.substring(10, 12)),
        int.parse(lastTime.substring(12, 14)),
      );
      return DateTime.now().difference(last).inMinutes < 5;
    } catch (_) {
      return false;
    }
  }

  String remainingTime(String lastTime) {
    if (lastTime.isEmpty) return '';
    try {
      final last = DateTime(
        int.parse(lastTime.substring(0, 4)),
        int.parse(lastTime.substring(4, 6)),
        int.parse(lastTime.substring(6, 8)),
        int.parse(lastTime.substring(8, 10)),
        int.parse(lastTime.substring(10, 12)),
        int.parse(lastTime.substring(12, 14)),
      );
      final remaining = const Duration(minutes: 5) - DateTime.now().difference(last);
      if (remaining.isNegative) return '';
      final m = remaining.inMinutes;
      final s = remaining.inSeconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Map<String, String> get bookiHomeData => _bookiHomeData;

  Map<String, String> get bookiLastTimeMap => _bookiLastTimeMap;

  List<BookiHomeData> get bookiHomeDataList => _bookiHomeDataList;
}
