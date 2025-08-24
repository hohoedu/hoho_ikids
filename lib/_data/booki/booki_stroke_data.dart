import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BookiStrokeData {
  final String phonetic;
  final String imagePath;
  final String voicePath;

  BookiStrokeData({
    required this.phonetic,
    required this.imagePath,
    required this.voicePath,
  });

  factory BookiStrokeData.fromJson(Map<String, dynamic> json) {
    return BookiStrokeData(
      phonetic: json['note'],
      imagePath: json['imgpath'],
      voicePath: json['voice'],
    );
  }
}

class BookiStrokeDataController extends GetxController {
  List<BookiStrokeData> _bookiStrokeDataList = <BookiStrokeData>[].obs;

  void setBookiStrokeDataList(List<BookiStrokeData> bookiStrokeDataList) {
    _bookiStrokeDataList = List.from(bookiStrokeDataList);
    update();
  }

  List<BookiStrokeData> get bookiStrokeDataList => _bookiStrokeDataList;
}
