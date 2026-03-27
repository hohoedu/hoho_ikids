import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

Future<bool> legacyPrivacyService({required String id, required String agreed}) async {
  String url = dotenv.get('INSERT_CHILD_URL');

  final Map<String, dynamic> requestData = {
    'id': id,
    'privacy_agreed': agreed,
  };

  Logger().d(requestData);

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));
    Logger().d(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      if (resultValue == "000") {
        return true;
      } else {
        oneButtonDialog(
          title: '개인정보 동의',
          content: '개인정보 동의 처리에 실패했습니다. 다시 시도해주세요.',
          onTap: () => Get.back(),
          buttonText: '확인',
        );
        return false;
      }
    }
  } catch (e) {
    Logger().d('e = $e');
    oneButtonDialog(
      title: '오류',
      content: '네트워크 오류가 발생했습니다.',
      onTap: () => Get.back(),
      buttonText: '확인',
    );
  }
  return false;
}
