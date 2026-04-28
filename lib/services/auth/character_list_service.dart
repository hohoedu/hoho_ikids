import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/character_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:logger/logger.dart';

Future<void> characterListService() async {
  final String url = dotenv.get('CHARACTER_LIST_URL');
  final characterController = Get.put(CharacterDataController());
  final userdata = Get.find<UserDataController>();

  final Map<String, dynamic> requestData = {
    'id': userdata.userData!.id,
    'yy': userdata.userData!.year,
  };

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));
    Logger().d(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);

      if (result['result'] == '0000') {
        final List<CharacterData> list =
        (result['data'] as List).map((e) => CharacterData.fromJson(e)).toList();
        characterController.setCharacterList(list, result['my_character']);

      }
    }
  } catch (e) {
    Logger().d('characterSelectService error = $e');
  }
}
