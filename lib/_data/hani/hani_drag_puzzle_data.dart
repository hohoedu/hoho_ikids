import 'package:get/get.dart';

class HaniDragPuzzleData {
  final String boardImage;
  final List<String> questionImages;
  final List<String> cardImages;
  final List<String> voices;

  HaniDragPuzzleData({
    required this.boardImage,
    required this.questionImages,
    required this.cardImages,
    required this.voices,
  });

  factory HaniDragPuzzleData.fromJson(Map<String, dynamic> json) {
    return HaniDragPuzzleData(
      boardImage: json["board_imgpath"],
      questionImages: List.generate(8, (i) => json["back${i + 1}_imgpath"]),
      cardImages: List.generate(8, (i) => json["card${i + 1}_imgpath"]),
      voices: List.generate(8, (i) => json["voice${i + 1}"]),
    );
  }
}

class HaniDragPuzzleDataController extends GetxController {
  List<HaniDragPuzzleData> _dragPuzzleDataList = <HaniDragPuzzleData>[].obs;

  void setDragPuzzleDataList(List<HaniDragPuzzleData> dragPuzzleDataList) {
    _dragPuzzleDataList = dragPuzzleDataList;
    update();
  }

  List<HaniDragPuzzleData> get dragPuzzleDataList => _dragPuzzleDataList;
}
