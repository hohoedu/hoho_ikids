import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/notice/notice_view_data.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeView extends StatelessWidget {
  const NoticeView({
    super.key,
    required this.noticeViewData,
  });

  final NoticeViewDataController noticeViewData;

  Future<void> moveToUrl(String videoUrl) async {
    final Uri url = Uri.parse(videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw '주소를 찾을 수 없음';
    }
  }

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
              final data = noticeViewData.noticeViewData;
              if (data == null) return const SizedBox.shrink();

              final imagePath = data.imagePath;
              final linkUrl = data.linkUrl;
              final type = data.type;

              Widget buildActionButton() {
                if (type == '1') {
                  return Image.asset('assets/images/icons/kakao.png', scale: 2, fit: BoxFit.cover);
                } else if (type == '2') {
                  return Image.asset('assets/images/icons/youtube.png', scale: 2, fit: BoxFit.cover);
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('자세히 보기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Icon(Icons.navigate_next_outlined),
                      ],
                    ),
                  );
                }
              }

              Widget buildLinkButton() {
                return Visibility(
                  visible: linkUrl.isNotEmpty,
                  child: Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      // onTap: () => moveToUrl(linkUrl),
                      onTap: () => showParentGateDialog(context, linkUrl),
                      child: Container(
                        width: 60.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(2, 4),
                            )
                          ],
                        ),
                        child: buildActionButton(),
                      ),
                    ),
                  ),
                );
              }

              Widget buildImageContent() {
                return FutureBuilder(
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
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: snapshot.data as Widget,
                        ),
                      ],
                    );
                  },
                );
              }

              Widget buildTextContent() {
                return Container(
                  color: const Color(0xFFFFF69D),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(data.note),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  imagePath.isNotEmpty ? buildImageContent() : buildTextContent(),
                  buildLinkButton(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<Widget> _loadImageWithDelay(String url) async {
    bool loadingShown = false;
    final completer = Completer<Widget>();

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
