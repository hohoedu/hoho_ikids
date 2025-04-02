import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/notice/notice_list_data.dart';
import 'package:hani_booki/_data/notice/notice_view_data.dart';
import 'package:hani_booki/services/notice/notice_view_service.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/appbar/notice_appbar.dart';
import 'package:hani_booki/widgets/notice/notice_widgets/notice_list.dart';
import 'package:hani_booki/widgets/notice/notice_widgets/notice_view.dart';
import 'package:logger/logger.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final noticeListData = Get.find<NoticeListDataController>();
  final noticeViewData = Get.find<NoticeViewDataController>();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: mBackWhite,
          body: Column(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: kToolbarHeight * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 8,
                        child: Center(
                          child: Text(
                            '호호에서 알려드려요!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.clear),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Row(
                  children: [
                    NoticeList(
                      noticeListData: noticeListData,
                    ),
                    NoticeView(noticeViewData: noticeViewData),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
