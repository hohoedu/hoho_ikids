import 'package:get/get.dart';

class HaniRecordHighFiveData {
  final String index;
  final String subject;
  final String summary;
  final String contentName1;
  final String contentCard1;
  final String contentCount1;
  final String contentName2;
  final String contentCard2;
  final String contentCount2;
  final String contentName3;
  final String contentCard3;
  final String contentCount3;
  final String contentName4;
  final String contentCard4;
  final String contentCount4;
  final String bestContent;
  final String bestContentValue;
  // final String basicScore1;
  // final String basicScore2;
  // final String basicScore3;
  // final String basicScore4;
  // final String score1;
  // final String score2;
  // final String score3;
  // final String score4;
  final String averageScore;

  HaniRecordHighFiveData({
    required this.index,
    required this.subject,
    required this.summary,
    required this.contentName1,
    required this.contentCard1,
    required this.contentCount1,
    required this.contentName2,
    required this.contentCard2,
    required this.contentCount2,
    required this.contentName3,
    required this.contentCard3,
    required this.contentCount3,
    required this.contentName4,
    required this.contentCard4,
    required this.contentCount4,
    required this.bestContent,
    required this.bestContentValue,
    // required this.basicScore1,
    // required this.basicScore2,
    // required this.basicScore3,
    // required this.basicScore4,
    // required this.score1,
    // required this.score2,
    // required this.score3,
    // required this.score4,
    required this.averageScore,
  });

  HaniRecordHighFiveData.fromJson(Map<String, dynamic> json)
      : index = json['idx'],
        subject = json['subject'],
        summary = json['note'],
        contentName1 = json['contentgb_1'],
        contentCard1 = json['contentgb_1_str'],
        contentCount1 = json['contentgb_1_cnt'],
        contentName2 = json['contentgb_2'],
        contentCard2 = json['contentgb_2_str'],
        contentCount2 = json['contentgb_2_cnt'],
        contentName3 = json['contentgb_3'],
        contentCard3 = json['contentgb_3_str'],
        contentCount3 = json['contentgb_3_cnt'],
        contentName4 = json['contentgb_4'],
        contentCard4 = json['contentgb_4_str'],
        contentCount4 = json['contentgb_4_cnt'],
        bestContent = json['best_contentgb'],
        bestContentValue = json['best_content_value'],
        // basicScore1 = json['contentgb_1_basic'],
        // basicScore2 = json['contentgb_2_basic'],
        // basicScore3 = json['contentgb_3_basic'],
        // basicScore4 = json['contentgb_4_basic'],
        // score1 = json['contentgb_1_jumsu'],
        // score2 = json['contentgb_2_jumsu'],
        // score3 = json['contentgb_3_jumsu'],
        // score4 = json['contentgb_4_jumsu'],
        averageScore = json['average_jumsu'];
}

class HaniRecordHighfiveDataController extends GetxController {
  final RxList<HaniRecordHighFiveData> _recordHighfiveDataList = <HaniRecordHighFiveData>[].obs;  // RxList로 선언

  void setHaniRecordHighfiveListData(List<HaniRecordHighFiveData> recordHighfiveDataList) {
    _recordHighfiveDataList.assignAll(recordHighfiveDataList);  // 데이터를 RxList에 추가
  }
  void clearData() {
    _recordHighfiveDataList.clear();
  }

  RxList<HaniRecordHighFiveData> get recordHighfiveDataList => _recordHighfiveDataList;  // RxList로 반환
}
