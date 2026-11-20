import 'package:get/get.dart';

/// 부키 바구니 문제 하나 (응답 list 의 항목): 인물 그림, 인물과 관련된 물건 3개, 관련 없는 물건 3개 (서버 이미지 URL)
class BookiBasketData {
  final int ilno;
  final String personImg;
  final List<String> answerImgs; // answer_img1~3
  final List<String> wrongImgs; // wrong_img1~3

  BookiBasketData({required this.ilno, required this.personImg, required this.answerImgs, required this.wrongImgs});

  // answer_img1, answer_img2… 처럼 번호가 이어지는 동안 읽음 (개수가 바뀌어도 그대로 읽힘)
  BookiBasketData.fromJson(Map<String, dynamic> json)
      : ilno = json['ilno'],
        personImg = json['person_img'] ?? '',
        answerImgs = [for (var i = 1; json['answer_img$i'] != null; i++) json['answer_img$i']],
        wrongImgs = [for (var i = 1; json['wrong_img$i'] != null; i++) json['wrong_img$i']];
}

class BookiBasketDataController extends GetxController {
  List<BookiBasketData> _bookiBasketDataList = <BookiBasketData>[].obs;

  void setBookiBasketDataList(List<BookiBasketData> bookiBasketDataList) {
    _bookiBasketDataList = List.from(bookiBasketDataList);
    update();
  }

  List<BookiBasketData> get bookiBasketDataList => _bookiBasketDataList;
}
