import 'package:get/get.dart';

/// 요리볼 카드 하나: 낱말(한자어)과 그림 (서버 이미지 URL)
typedef HaniCookingCard = ({String word, String img});

/// 하니 요리 문제 하나 (응답 list 의 항목): 주제, 주제에 맞는 카드 4장, 안 맞는 카드 2장
class HaniCookingData {
  final int ilno;
  final String topic; // munje. 예: 자연
  final List<HaniCookingCard> answers; // ans1~4
  final List<HaniCookingCard> wrongs; // wrong1~2

  HaniCookingData({required this.ilno, required this.topic, required this.answers, required this.wrongs});

  // ans1·ans1_img, ans2… 처럼 번호가 이어지는 동안 카드로 묶음 (개수가 바뀌어도 그대로 읽힘)
  HaniCookingData.fromJson(Map<String, dynamic> json)
      : ilno = json['ilno'],
        topic = (json['munje'] ?? '').toString().trim(), // "가족 " 처럼 뒤에 공백이 붙어 옴
        answers = [
          for (var i = 1; json['ans$i'] != null; i++) (word: json['ans$i'], img: json['ans${i}_img'] ?? ''),
        ],
        wrongs = [
          for (var i = 1; json['wrong$i'] != null; i++) (word: json['wrong$i'], img: json['wrong${i}_img'] ?? ''),
        ];
}

class HaniCookingDataController extends GetxController {
  List<HaniCookingData> _haniCookingDataList = <HaniCookingData>[].obs;
  String _mainImg = ''; // 응답 맨 위 main_img (요리볼 그림)

  void setHaniCookingDataList(List<HaniCookingData> haniCookingDataList, {String mainImg = ''}) {
    _haniCookingDataList = List.from(haniCookingDataList);
    _mainImg = mainImg;
    update();
  }

  List<HaniCookingData> get haniCookingDataList => _haniCookingDataList;
  String get mainImg => _mainImg;
}
