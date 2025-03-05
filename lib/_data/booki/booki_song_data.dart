import 'package:get/get.dart';

class BookiSongData {
  final String vimeoId;

  BookiSongData({
    required this.vimeoId,
  });

  BookiSongData.fromJson(Map<String, dynamic> json) : vimeoId = json['song'];
}

class BookiSongDataController extends GetxController {
  List<BookiSongData> _bookiSongDataList = <BookiSongData>[].obs;

  void setBookiSongDataList(List<BookiSongData> bookiSongDataList) {
    _bookiSongDataList = List.from(bookiSongDataList);
    update();
  }

  List<BookiSongData> get bookiSongDataList => _bookiSongDataList;
}
