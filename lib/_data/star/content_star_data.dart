import 'package:get/get.dart';

class ContentStarData {
  final String index;
  final String subject;
  final String note;
  final List<String> contentList;
  final String score;

  ContentStarData({
    required this.index,
    required this.subject,
    required this.note,
    required this.contentList,
    required this.score,
  });

  factory ContentStarData.fromJson(Map<String, dynamic> json) {
    List<String> contentList = [];

    for (int i = 1; i <= 4; i++) {
      final content = json['contentgb_${i}_str'] ?? '';
      if (content.trim().isNotEmpty) {
        contentList.add(content);
      }
    }

    return ContentStarData(
      index: json['idx'] ?? '',
      subject: json['subject'] ?? '',
      note: json['note'] ?? '',
      contentList: contentList,
      score: json['average_jumsu'] ?? '',
    );
  }
}

class ContentStarDataController extends GetxController {
  RxList<ContentStarData> contentStarDataList = <ContentStarData>[].obs;

  void setContentStarDataList(List<ContentStarData> contentStarDataList) {
    this.contentStarDataList.value = contentStarDataList;
  }
}
