import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class BookiRecordReadingData {
  final String bookCode;
  final String note;
  final String subject;
  final String bookName;
  final String check;
  final String title;

  BookiRecordReadingData({
    required this.bookCode,
    required this.note,
    required this.subject,
    required this.bookName,
    required this.title,
    required this.check,
  });

  BookiRecordReadingData.fromJson(Map<String, dynamic> json)
      : bookCode = json['bcode'] ?? '',
        note = json['note'] ?? '',
        subject = json['subcat'] ?? '',
        bookName = json['bname'] ?? '',
        title = json['iname'] ?? '',
        check = json['chk'] ?? '';
}

class BookiRecordReadingDataController extends GetxController {
  final RxList<BookiRecordReadingData> _recordReadingDataList = <BookiRecordReadingData>[].obs;

  void setBookiRecordReadingListData(List<BookiRecordReadingData> recordReadingDataList) {
    _recordReadingDataList.assignAll(recordReadingDataList);  // RxList에 데이터를 추가하는 방식
  }

  void clearData() {
    _recordReadingDataList.clear();
  }

  RxList<BookiRecordReadingData> get recordReadingDataList => _recordReadingDataList;  // <- 여기서도 RxList로 반환해야 함
}
