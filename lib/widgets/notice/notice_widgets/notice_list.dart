import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/notice/notice_list_data.dart';
import 'package:hani_booki/services/notice/notice_view_service.dart';
import 'package:hani_booki/utils/badge_controller.dart';
import 'package:hani_booki/utils/bubble_clip.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:badges/badges.dart' as badges;
import 'package:logger/logger.dart';

class NoticeList extends StatefulWidget {
  const NoticeList({super.key, required this.noticeListData});

  final NoticeListDataController noticeListData;

  @override
  State<NoticeList> createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  bool isNotice = false;
  int currentIndex = 0;
  final badgeController = Get.find<BadgeController>();

  bool isNewActive(String createdAt) {
    final now = DateTime.now();
    DateTime notificationDate = DateTime.parse(createdAt);

    return now.difference(notificationDate).inDays < 14;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 4.0),
        child: Container(
          width: 10,
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(25)),
          child: ListView.builder(
            itemCount: widget.noticeListData.noticeDataList.length,
            itemBuilder: (context, index) {
              final noticeData = widget.noticeListData.noticeDataList[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        currentIndex = index;
                      });
                      badgeController.markNotificationAsRead(noticeData.index);
                      await noticeViewService(
                        noticeData.index,
                        noticeData.type,
                      );
                    },
                    // child: Obx(
                    //   () => badges.Badge(
                    //     position: badges.BadgePosition.topEnd(top: 5, end: 0),
                    //     showBadge: badgeController.isBadgeVisible.value,
                    //     badgeStyle: badges.BadgeStyle(
                    //       badgeColor: Colors.red,
                    //       padding: EdgeInsets.all(5),
                    //     ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: noticeTitleColor[noticeData.type],
                              border: Border.all(
                                width: 3,
                                color: index == currentIndex
                                    ? noticeTitleActiveColor[noticeData.type]!
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    '${noticeIcon[noticeData.type]}',
                                    scale: 2.5,
                                  ),
                                ),
                                Text(
                                  formatNoticeTitle(noticeData.title),
                                  // formatNoticeTitle(noticeData.title),
                                  style: TextStyle(
                                    color: fontWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  //   ),
                  // ),
                  Visibility(
                    visible: isNewActive(noticeData.createdAt),
                    child: SizedBox(width: 30, child: Image.asset('assets/images/icons/board_new.png')),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
