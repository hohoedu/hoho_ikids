import 'package:get/get.dart';

class BookiFindDiffData {
  final String image_1;
  final String image_2;
  final List<List<dynamic>> findAdress;

  BookiFindDiffData({
    required this.image_1,
    required this.image_2,
    required this.findAdress,
  });

  factory BookiFindDiffData.fromJson(Map<String, dynamic> json) {
    List<List<dynamic>> parseFindAreas() {
      final areas = <List<dynamic>>[];
      for (int i = 1; i <= 4; i++) {
        final areaCode = json['find${i}_area_code'];
        if (areaCode != null) {
          final coords =
              areaCode.split(',').map((e) => double.parse(e)).toList();
          if (coords.length == 4) areas.add(coords);
        }
      }
      return areas;
    }

    return BookiFindDiffData(
      image_1: json['imgsrc1'],
      image_2: json['imgsrc2'],
      findAdress: parseFindAreas(),
    );
  }
}

class BookiFindDiffDataController extends GetxController {
  List<BookiFindDiffData> _bookiFindDiffDataList = <BookiFindDiffData>[].obs;

  void setBookiFindDiffDataList(List<BookiFindDiffData> bookiFindDiffDataList) {
    _bookiFindDiffDataList = List.from(bookiFindDiffDataList);
    update();
  }

  List<BookiFindDiffData> get bookiFindDiffDataList => _bookiFindDiffDataList;
}
