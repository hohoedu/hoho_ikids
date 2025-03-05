import 'package:get/get.dart';

class BookiStoryData {
  final String vimeoId;

  BookiStoryData({
    required this.vimeoId,
  });

  BookiStoryData.fromJson(Map<String, dynamic> json) : vimeoId = json['story'];
}

class BookiStoryDataController extends GetxController {
  List<BookiStoryData> _bookiStoryDataList = <BookiStoryData>[].obs;

  void setBookiStoryDataList(List<BookiStoryData> bookiStoryDataList) {
    _bookiStoryDataList = List.from(bookiStoryDataList);
    update();
  }

  List<BookiStoryData> get bookiStoryDataList => _bookiStoryDataList;
}
