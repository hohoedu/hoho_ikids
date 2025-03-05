import 'package:get/get.dart';

class BookiMatchData {
  final String logo;
  final List<String> frontImages;
  final List<String> backImages;
  final List<Map<String, String>> backImagePairs;

  BookiMatchData(
      {required this.logo,
      required this.frontImages,
      required this.backImages,
      required this.backImagePairs});

  factory BookiMatchData.fromJson(Map<String, dynamic> json) {
    List<String> frontImages = [];
    List<String> backImages = [];
    List<Map<String, String>> backImagePairs = [];

    json.forEach((key, value) {
      if (key.startsWith('frontImg_')) {
        frontImages.add(value);
      } else if (key.startsWith('backImg_')) {
        backImages.add(value);
      }
    });

    for (int i = 0; i < backImages.length; i += 2) {
      if (i + 1 < backImages.length) {
        backImagePairs.add({
          "first": backImages[i],
          "second": backImages[i + 1],
        });
      }
    }

    return BookiMatchData(
      logo: json['logo'],
      frontImages: frontImages,
      backImages: backImages,
      backImagePairs: backImagePairs,
    );
  }
}

class BookiMatchDataController extends GetxController {
  List<BookiMatchData> _bookiMatchDataList = <BookiMatchData>[].obs;

  void setBookiMatchDataList(List<BookiMatchData> bookiMatchDataList) {
    _bookiMatchDataList = List.from(bookiMatchDataList);
    update();
  }

  List<BookiMatchData> get bookiMatchDataList => _bookiMatchDataList;
}
