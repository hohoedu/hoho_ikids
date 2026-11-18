import 'package:get/get.dart';

/// 스토리보드 장면 하나: 그림, 문장, 문장 읽기 음성 (서버 URL 또는 앱 에셋 경로)
typedef BookiStoryScene = ({String img, String text, String voice});

/// 부키 스토리보드 이야기 하나 (응답 list 의 항목). 장면 순서 = 정답 순서
class BookiStoryBoardData {
  final int ilno;
  final String title;
  final List<BookiStoryScene> scenes;

  BookiStoryBoardData({required this.ilno, required this.title, required this.scenes});

  // img1·txt1·voice1, img2… 를 번호 순서대로 장면으로 묶음
  BookiStoryBoardData.fromJson(Map<String, dynamic> json)
      : ilno = json['ilno'],
        title = json['title'] ?? '',
        scenes = [
          for (var i = 1; json['img$i'] != null; i++)
            (img: json['img$i'], text: json['txt$i'] ?? '', voice: json['voice$i'] ?? ''),
        ];
}

class BookiStoryBoardDataController extends GetxController {
  List<BookiStoryBoardData> _bookiStoryBoardDataList = <BookiStoryBoardData>[].obs;

  void setBookiStoryBoardDataList(List<BookiStoryBoardData> bookiStoryBoardDataList) {
    _bookiStoryBoardDataList = List.from(bookiStoryBoardDataList);
    update();
  }

  List<BookiStoryBoardData> get bookiStoryBoardDataList => _bookiStoryBoardDataList;
}
