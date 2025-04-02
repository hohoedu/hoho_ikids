import 'package:get/get.dart';

class NoticeListData {
  final String index;
  final String type;
  final String typeString;
  final String title;
  final String createdAt;

  NoticeListData({
    required this.index,
    required this.type,
    required this.typeString,
    required this.title,
    required this.createdAt,
  });

  NoticeListData.fromJson(Map<String, dynamic> json)
      : index = json['idx'],
        type = json['gb'],
        typeString = json['gbstr'],
        title = json['title'],
        createdAt = json['idate'];
}

class NoticeListDataController extends GetxController {
  RxList<NoticeListData> noticeDataList = <NoticeListData>[].obs;

  void setNoticeListData(List<NoticeListData> newDataList) {
    noticeDataList.value = newDataList;
  }
}
