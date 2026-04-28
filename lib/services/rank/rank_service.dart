import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/rank/rank_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

Future<void> rankService(String hosu) async {
  final String url = dotenv.get('RANK_URL');
  final rankController = Get.find<RankDataController>();
  final userdata = Get.find<UserDataController>();

  final Map<String, dynamic> requestData = {
    'schoolid': userdata.userData!.schoolId,
    'yy': userdata.userData!.year,
    'hosu': hosu,
  };

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));
    Logger().d(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      final String code = result['result'];

      if (code == '0000') {
        final List<RankItem> list = (result['list'] as List).map((e) => RankItem.fromJson(e)).toList();
        rankController.setCurrentList(list);
      } else if (code == '9999') {
        final String? openDate = result['open_date'];
        rankController.setOpenDate(openDate);
      } else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '네트워크 상태를 확인해주세요.',
          onTap: () => Get.back(),
          buttonText: '확인',
        );
      }
    }
  } catch (e) {
    Logger().d('rankService error = $e');
  }
}
