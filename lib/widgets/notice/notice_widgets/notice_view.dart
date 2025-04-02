import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/notice/notice_view_data.dart';
import 'package:logger/logger.dart';

class NoticeView extends StatelessWidget {
  const NoticeView({
    super.key,
    required this.noticeViewData,
  });

  final NoticeViewDataController noticeViewData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
          ),
          child: GestureDetector(
            onTap: () => EasyLoading.dismiss(),
            child: Obx(() {
              final imagePath = noticeViewData.noticeViewData?.imagePath ?? '';

              return imagePath.isNotEmpty
                  ? FutureBuilder(
                      future: _loadImageWithDelay(imagePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.hasError) {
                          EasyLoading.dismiss();
                          return const Center(child: Text('이미지 로드 오류'));
                        }

                        EasyLoading.dismiss();
                        return ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: snapshot.data as Widget,
                            ),
                          ],
                        );
                      },
                    )
                  : Container();
            }),
          ),
        ),
      ),
    );
  }

  Future<Widget> _loadImageWithDelay(String url) async {
    bool loadingShown = false;
    final completer = Completer<Widget>();

    // 0.5초 후에 로딩 표시하기 (이미지가 로드되지 않았으면 표시)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!completer.isCompleted) {
        EasyLoading.show(status: '로딩 중...', dismissOnTap: true);
        loadingShown = true;
      }
    });

    try {
      final image = Image.network(url, fit: BoxFit.contain);

      // 이미지 로딩 완료까지 대기 (캐싱 사용)
      await precacheImage(image.image, Get.context!);

      if (loadingShown) EasyLoading.dismiss();
      completer.complete(image);
    } catch (e) {
      if (loadingShown) EasyLoading.dismiss();
      completer.completeError(e);
    }

    return completer.future;
  }
}
