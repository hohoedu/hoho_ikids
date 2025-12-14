import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BookiStrokeData {
  final String phonetic;
  final String svgPath;
  final String voicePath;
  final String sentenceVoice;
  final String pngPath;

  BookiStrokeData({
    required this.phonetic,
    required this.svgPath,
    required this.voicePath,
    required this.sentenceVoice,
    required this.pngPath,
  });

  factory BookiStrokeData.fromJson(Map<String, dynamic> json) {
    return BookiStrokeData(
      phonetic: json['note'],
      svgPath: json['imgpath'],
      voicePath: json['voice'],
      sentenceVoice: json['voice'].toString().replaceAll('.mp3', '_2.mp3'),
      pngPath: json['pngimgpath'],
    );
  }
}

class BookiStrokeDataController extends GetxController {
  List<BookiStrokeData> _bookiStrokeDataList = <BookiStrokeData>[].obs;

  void setBookiStrokeDataList(List<BookiStrokeData> bookiStrokeDataList) {
    _bookiStrokeDataList = List.from(bookiStrokeDataList);
    update();
  }

  List<BookiStrokeData> get bookiStrokeDataList => _bookiStrokeDataList;
}
