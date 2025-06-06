import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/http.dart';
import 'package:hani_booki/_data/notice/notice_view_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

// 공지사항 개별 내용
Future<void> noticeViewService(idx, gb) async {
  final noticeViewDataController = Get.put(NoticeViewDataController());
  String url = dotenv.get('NOTICE_VIEW_URL');

  final Map<String, dynamic> requestData = {
    'idx': idx,
    'gb': gb,
  };
  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final NoticeViewData noticeViewData = NoticeViewData.fromJson(resultList, type: gb);
        noticeViewDataController.setNoticeViewData(noticeViewData);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        oneButtonDialog(
          title: '불러오기 실패',
          content: '데이터가 없습니다.',
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
