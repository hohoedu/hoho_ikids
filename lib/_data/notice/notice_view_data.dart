import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class NoticeViewData {
  final String title;
  final String imagePath;
  final String note;
  final String typeString;
  final String linkUrl;

  NoticeViewData({
    required this.title,
    required this.imagePath,
    required this.note,
    required this.typeString,
    required this.linkUrl,
  });

  NoticeViewData.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        imagePath = json['imgpath'] ?? '',
        note = json['note'] ?? '',
        typeString = json['gb_str'] ?? '',
        linkUrl = json['linkurl'] ?? '';
}

class NoticeViewDataController extends GetxController {
  final Rx<NoticeViewData?> _noticeViewData = Rx<NoticeViewData?>(null);

  void setNoticeViewData(NoticeViewData noticeViewData) {
    _noticeViewData.value = noticeViewData;
    update();
  }

  NoticeViewData? get noticeViewData => _noticeViewData.value;
}
