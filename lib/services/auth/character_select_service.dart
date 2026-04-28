import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/auth/character_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/services/auth/character_list_service.dart';
import 'package:logger/logger.dart';

Future<void> characterSaveService(String selected) async {
  final String url = dotenv.get('CHARACTER_SELECT_URL');
  final userdata = Get.find<UserDataController>();

  final Map<String, dynamic> requestData = {'id': userdata.userData!.id, 'yy': userdata.userData!.year, 'character_key': selected};

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));
    Logger().d(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.data);
      if (result['result'] == '0000') {
        await characterListService();
        await showDialog(
          context: Get.context!,
          builder: (context) {
            Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.symmetric(vertical: 25.w, horizontal: 10.h),
              content: Text(
                '${result['message']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8.sp),
              ),
            );
          },
        );
      }
    }
  } catch (e) {
    Logger().d('characterSelectService error = $e');
  }
}
