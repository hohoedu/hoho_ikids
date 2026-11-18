import 'package:get/get.dart';

/// 문장 완성 보기 하나: 단어와 스티커 그림 (서버 URL 또는 앱 에셋 경로)
typedef BookiSentenceOption = ({String word, String img});

/// 부키 문장 완성 문제 하나 (응답 list 의 항목)
class BookiSentenceData {
  final int ilno;
  final String img; // 인물 그림
  final String before; // 빈칸 앞 문장
  final String after; // 빈칸 뒤 문장
  final BookiSentenceOption answer;
  final BookiSentenceOption wrong;
  final String voice; // 문장 읽기 음성

  BookiSentenceData({
    required this.ilno,
    required this.img,
    required this.before,
    required this.after,
    required this.answer,
    required this.wrong,
    required this.voice,
  });

  /// munje 의 첫 번째 ? 자리가 빈칸 박스. 예: "정조는 수원에 ?을 쌓았어요." → "정조는 수원에 " + [박스] + "을 쌓았어요."
  factory BookiSentenceData.fromJson(Map<String, dynamic> json) {
    final String munje = json['munje'] ?? '';
    final blank = munje.indexOf('?');
    return BookiSentenceData(
      ilno: json['ilno'],
      img: json['img'] ?? '',
      before: blank < 0 ? munje : munje.substring(0, blank),
      after: blank < 0 ? '' : munje.substring(blank + 1),
      answer: (word: json['ans'] ?? '', img: json['answer_img'] ?? ''),
      wrong: (word: json['wrong'] ?? '', img: json['wrong_img'] ?? ''),
      voice: json['voice'] ?? '',
    );
  }
}

class BookiSentenceDataController extends GetxController {
  List<BookiSentenceData> _bookiSentenceDataList = <BookiSentenceData>[].obs;

  void setBookiSentenceDataList(List<BookiSentenceData> bookiSentenceDataList) {
    _bookiSentenceDataList = List.from(bookiSentenceDataList);
    update();
  }

  List<BookiSentenceData> get bookiSentenceDataList => _bookiSentenceDataList;
}
