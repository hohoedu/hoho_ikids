import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class BookiRecordLearningData {
  final String leverString;
  final String lifeTopic;
  final String tenacityTopic;
  final String chinese;
  final String subject;
  final String topicNote;
  final String part_1;
  final String note_1;
  final String part_2;
  final String note_2;
  final String part_3;
  final String note_3;
  final String part_4;
  final String note_4;
  final String part_5;
  final String note_5;
  final String part_6;
  final String note_6;

  BookiRecordLearningData({
    required this.leverString,
    required this.lifeTopic,
    required this.tenacityTopic,
    required this.chinese,
    required this.subject,
    required this.topicNote,
    required this.part_1,
    required this.note_1,
    required this.part_2,
    required this.note_2,
    required this.part_3,
    required this.note_3,
    required this.part_4,
    required this.note_4,
    required this.part_5,
    required this.note_5,
    required this.part_6,
    required this.note_6,
  });

  BookiRecordLearningData.fromJson(Map<String, dynamic> json)
      : leverString = json['level_str'] ?? '',
        lifeTopic = json['lifeTopics'] ?? '',
        tenacityTopic = json['personalityTopic'] ?? '',
        chinese = json['newChinese'] ?? '',
        subject = json['subject'] ?? '',
        topicNote = json['personalityTopic_note'] ?? '',
        part_1 = json['part1'] ?? '',
        note_1 = json['part1_note'] ?? '',
        part_2 = json['part2'] ?? '',
        note_2 = json['part2_note'] ?? '',
        part_3 = json['part3'] ?? '',
        note_3 = json['part3_note'] ?? '',
        part_4 = json['part4'] ?? '',
        note_4 = json['part4_note'] ?? '',
        part_5 = json['part5'] ?? '',
        note_5 = json['part5_note'] ?? '',
        part_6 = json['part6'] ?? '',
        note_6 = json['part6_note'] ?? '';
}

class BookiRecordLearningDataController extends GetxController {
  final Rx<BookiRecordLearningData?> _recordLearningData = Rx<BookiRecordLearningData?>(null);

  void setBookiRecordLearningData(BookiRecordLearningData recordLearningData) {
    _recordLearningData.value = recordLearningData;
    update();
  }

  void clearBookiRecordLearningData() {
    _recordLearningData.value = null;
    update();
  }

  BookiRecordLearningData? get recordLearningData => _recordLearningData.value;
}
