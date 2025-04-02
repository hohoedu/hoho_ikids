import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/sibling_data.dart';
import 'package:logger/logger.dart';

class BookiRecordHomeData {
  final String teacherId;
  final String keyCode;
  final String category;
  final String schoolId;
  final String teacherName;
  final String studentId;
  final String studentName;

  BookiRecordHomeData({
    required this.teacherId,
    required this.keyCode,
    required this.category,
    required this.schoolId,
    required this.teacherName,
    required this.studentId,
    required this.studentName,
  });

  BookiRecordHomeData.fromJson(Map<String, dynamic> json)
      : teacherId = json['teacherid'] ?? '',
        keyCode = json['pin'] ?? '',
        category = json['hosu'] ?? '',
        schoolId = json['schoolid'] ?? '',
        teacherName = json['teachername'] ?? '',
        studentId = json['stuid'] ?? '',
        studentName = json['stuname'] ?? '';
}

class BookiRecordHomeDataController extends GetxController {
  final Rx<BookiRecordHomeData?> _recordHomeData = Rx<BookiRecordHomeData?>(null);

  void setBookiRecordHomeData(BookiRecordHomeData recordHomeData) {
    _recordHomeData.value = recordHomeData;
    update();
  }

  void clearData() {
    _recordHomeData.value= null;
    update();
  }
  BookiRecordHomeData? get recordHomeData => _recordHomeData.value;
}
