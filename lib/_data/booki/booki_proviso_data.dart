import 'package:get/get.dart';

/// 글 단서 하나: 문장과 읽기 음성
typedef BookiProvisoTextClue = ({String text, String voice});

/// 부키 단서 찾기 문제 하나 (응답 list 의 항목).
/// 자람(J)은 글 단서 clue1~3 + clue_mp3_1~3, 키움·만남은 그림 단서 clue_img1~2 로 옴
class BookiProvisoData {
  final int ilno;
  final List<BookiProvisoTextClue> textClues;
  final List<String> imageClues;
  final String answerImg; // 정답 인물
  final String wrongImg; // 오답 인물

  BookiProvisoData({
    required this.ilno,
    required this.textClues,
    required this.imageClues,
    required this.answerImg,
    required this.wrongImg,
  });

  /// 그림 단서가 있으면 그림 문제, 없으면 글 문제 (과정 대신 받은 데이터로 판단)
  bool get isImage => imageClues.isNotEmpty;

  BookiProvisoData.fromJson(Map<String, dynamic> json)
      : ilno = json['ilno'],
        // 빈 값(null·"")은 건너뜀
        textClues = [
          for (var i = 1; i <= 3; i++)
            if ((json['clue$i'] ?? '').toString().isNotEmpty)
              (text: json['clue$i'] as String, voice: json['clue_mp3_$i'] ?? ''),
        ],
        imageClues = [
          for (var i = 1; i <= 2; i++)
            if ((json['clue_img$i'] ?? '').toString().isNotEmpty) json['clue_img$i'] as String,
        ],
        answerImg = json['answer_img'] ?? '',
        wrongImg = json['wrong_img'] ?? '';
}

class BookiProvisoDataController extends GetxController {
  List<BookiProvisoData> _bookiProvisoDataList = <BookiProvisoData>[].obs;

  void setBookiProvisoDataList(List<BookiProvisoData> bookiProvisoDataList) {
    _bookiProvisoDataList = List.from(bookiProvisoDataList);
    update();
  }

  List<BookiProvisoData> get bookiProvisoDataList => _bookiProvisoDataList;
}
