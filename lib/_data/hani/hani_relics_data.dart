import 'package:get/get.dart';

/// 하니 유물찾기 문제 하나 (응답 list 의 항목): 모래 속 그림, 정답 보기, 오답 보기 (서버 이미지 URL)
class HaniRelicsData {
  final int ilno;
  final String seekImg; // 긁어서 찾는 그림
  final String answerImg; // 정답 보기
  final String wrongImg; // 오답 보기

  HaniRelicsData({required this.ilno, required this.seekImg, required this.answerImg, required this.wrongImg});

  HaniRelicsData.fromJson(Map<String, dynamic> json)
      : ilno = json['ilno'],
        seekImg = json['seek_img'] ?? '',
        answerImg = json['answer_img'] ?? '',
        wrongImg = json['wrong_img'] ?? '';
}

class HaniRelicsDataController extends GetxController {
  List<HaniRelicsData> _haniRelicsDataList = <HaniRelicsData>[].obs;

  void setHaniRelicsDataList(List<HaniRelicsData> haniRelicsDataList) {
    _haniRelicsDataList = List.from(haniRelicsDataList);
    update();
  }

  List<HaniRelicsData> get haniRelicsDataList => _haniRelicsDataList;
}
