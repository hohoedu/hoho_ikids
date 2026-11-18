import 'package:get/get.dart';

/// 부키 바구니 데이터
class BookiBasketData {
  // TODO: 응답 스펙 나오면 필드로 바꾸기. 지금은 받은 그대로 보관
  final Map<String, dynamic> raw;

  BookiBasketData({required this.raw});

  BookiBasketData.fromJson(Map<String, dynamic> json) : raw = json;
}

class BookiBasketDataController extends GetxController {
  List<BookiBasketData> _bookiBasketDataList = <BookiBasketData>[].obs;

  void setBookiBasketDataList(List<BookiBasketData> bookiBasketDataList) {
    _bookiBasketDataList = List.from(bookiBasketDataList);
    update();
  }

  List<BookiBasketData> get bookiBasketDataList => _bookiBasketDataList;
}
