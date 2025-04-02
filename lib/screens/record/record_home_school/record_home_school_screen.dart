import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/star/content_star_data.dart';
import 'package:hani_booki/_data/star/report_star_data.dart';
import 'package:hani_booki/_data/star/star_data.dart';
import 'package:hani_booki/screens/record/record_home_school/record_home_widgets/record_graph.dart';
import 'package:hani_booki/screens/record/record_home_school/record_home_widgets/record_list.dart';

import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:logger/logger.dart';

class RecordHomeSchoolScreen extends StatefulWidget {
  final String type;
  final String keyCode;

  const RecordHomeSchoolScreen({super.key, required this.type, required this.keyCode});

  @override
  State<RecordHomeSchoolScreen> createState() => _RecordHomeSchoolScreenState();
}

class _RecordHomeSchoolScreenState extends State<RecordHomeSchoolScreen> {
  final star = Get.find<ReportStarDataController>();

  final contentStar = Get.find<ContentStarDataController>();

  @override
  void initState() {
    Get.find<BgmController>().pauseBgm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: const MainAppBar(
        title: '',
        isContent: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.85,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: RecordList(
                      type: widget.type,
                      keyCode: widget.keyCode,
                    )),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.7,
                      child: Container(
                        decoration: BoxDecoration(color: Color(0xFFFFF3C8), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:widget.type == 'hani'? 
                                    Color(0xFFFF754C) : Color(0xFF00BCA8),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Image.asset(
                                            'assets/images/icons/total_star.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Obx(
                                                  () =>
                                                  Text(
                                                    '${star.totalStar.value}개\n획득',
                                                    style: TextStyle(
                                                      color: fontWhite,
                                                      fontSize: 8.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: RecordGraph(contentStar: contentStar, type: widget.type),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
