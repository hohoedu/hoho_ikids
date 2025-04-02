import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/notice/notice_list_data.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';

class AlertScreen extends StatelessWidget {
  final noticeData = Get.find<NoticeListDataController>();
  final bool isDevelop = false;

  AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: MainAppBar(
        title: ' ',
        isContent: false,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/icons/bell.png',
                      scale: 2.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '알림',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (noticeData.noticeDataList.isEmpty) {
              return Expanded(
                flex: 8,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              return Expanded(
                flex: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: noticeData.noticeDataList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.8 / 3.5,
                          decoration: BoxDecoration(color: mBackWhite, borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      noticeData.noticeDataList[index].typeString,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF737B8A)),
                                    ),
                                    Text(
                                      formatDateDifference(noticeData.noticeDataList[index].createdAt),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF777F8D)),
                                    )
                                  ],
                                ),
                                Text(
                                  noticeData.noticeDataList[index].title,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF37383A)),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
