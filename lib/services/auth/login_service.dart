import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_core/notification/token_management.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_select_verification_screen.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_twice_verification_screen.dart';
import 'package:hani_booki/screens/auth/legacy/legacy_parent_screen.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/services/auth/ebook_status_manager_service.dart';
import 'package:hani_booki/services/auth/ebook_status_service.dart';
import 'package:hani_booki/services/sibling_service.dart';
import 'package:hani_booki/utils/encryption.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 로그인 서비스
Future<void> loginService(id, password, isAutoLoginChecked) async {
  final userDataController = Get.put(UserDataController(), permanent: true);
  final storage = Get.find<FlutterSecureStorage>();
  String url = dotenv.get('LOGIN_2026_URL');
  bool isManager = password == 'hoho999999999';

  String hashedPassword = md5_convertHash(password);
  final Map<String, dynamic> requestData = {
    'id': id,
    'pwd': hashedPassword,
  };
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      // 7777 (작년 사용하던 유저)
      if (resultValue == '7777') {
        if (!isManager) {
          // await getToken(id);
        }
        oneButtonDialog(
          title: '로그인',
          content: '2026년 새학기가 시작되었어요!\n유치원 또는 어린이집에서 안내해 드린 신규 수업코드를 입력해 주세요.',
          onTap: () {
            Get.back();
            Get.to(
              () => JoinSelectVerificationScreen(
                loginCode: resultValue,
                id: id,
                password: password,
                isAutoLoginChecked: isAutoLoginChecked,
              ),
            );
          },
          buttonText: '확인',
        );
        return;
      }
      // 6666 (기관코드가 없는 유저)
      else if (resultValue == '6666') {
        if (!isManager) {
          // await getToken(id);
        }
        Get.to(
          () => JoinSelectVerificationScreen(
            loginCode: resultValue,
            id: id,
            password: password,
            isAutoLoginChecked: isAutoLoginChecked,
          ),
        );
        return;
      }
      // 정상적으로 로그인 된 유저
      else if (resultValue == "0000") {
        if (!isManager) {
          await getToken(id);
        }
        if (isAutoLoginChecked) {
          await storage.write(key: 'user_id', value: id);
          await storage.write(key: 'user_pwd', value: password);
        }

        final UserData userData = UserData.fromJson(resultList, id);
        userDataController.setUserData(userData);
        if (userData.parentName.isEmpty || userData.parentName == '' || userData.parentName == '*') {
          Get.to(() => LegacyParentScreen(userData, id));
          return;
        } else {
          if (int.parse(userData.siblingCount) >= 2) {
            await siblingService(userData.parentTel);
          } else {
            if (userData.userType == 'M' || userData.userType == 'T') {
              await ebookStatusManagerService(userData.schoolId, userData.year);
            } else {
              await ebookStatusService(id, userData.schoolId, userData.year);
            }
          }
        }
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        oneButtonDialog(
          title: '로그인',
          content: resultList['message'],
          onTap: () => Get.back(),
          buttonText: '확인',
        );
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
