import 'package:get/get.dart';

class CharacterData {
  final String id;
  // final String label;
  final String imageName;

  CharacterData({
    required this.id,
    // required this.label,
    required this.imageName,
  });

  factory CharacterData.fromJson(Map<String, dynamic> json) {
    final key = json['character_key'] as String;
    final isHani = key.startsWith('H');
    return CharacterData(
      id: key,
      // label: isHani ? '하니' : '부키',
      imageName: json['character_key'],
    );
  }
}

class CharacterDataController extends GetxController {
  RxList<CharacterData> characterList = <CharacterData>[].obs;
  RxString myCharacter = ''.obs;

  void setCharacterList(List<CharacterData> list, String myChar) {
    characterList.value = list;
    myCharacter.value = myChar;
  }

  void updateMyCharacter(String characterKey) {
    myCharacter.value = characterKey;
  }

}
