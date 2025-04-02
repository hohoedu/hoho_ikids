import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/_data/record/booki_record_home_data.dart';
import 'package:hani_booki/_data/record/hani_record_home_data.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_screen.dart';
import 'package:hani_booki/screens/record/record_class_screen/record_class_screen.dart';
import 'package:hani_booki/screens/record/record_home_school/record_home_school_screen.dart';
import 'package:hani_booki/services/kidok/kidok_bookcase_service.dart';
import 'package:hani_booki/services/kidok/kidok_chart_service.dart';
import 'package:hani_booki/services/kidok/kidok_sublist_service.dart';
import 'package:hani_booki/services/record/booki/booki_record_home_service.dart';
import 'package:hani_booki/services/record/booki/booki_record_learning_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_highfive_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_home_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_learning_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_tenacity_service.dart';
import 'package:hani_booki/services/record/report_star_service.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:logger/logger.dart';

class RecordScreen extends StatefulWidget {
  final String type;
  final String keyCode;
  final userData = Get.find<UserDataController>();

  RecordScreen({super.key, required this.type, required this.keyCode});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().pauseBgm();
  }

  Future<String> checkRecordServices() async {
    final haniRecordController = Get.put(HaniRecordHomeDataController());
    final bookiRecordController = Get.put(BookiRecordHomeDataController());

    await haniRecordHomeService();
    final haniData = haniRecordController.recordHomeData;

    await bookiRecordHomeService();
    final bookiData = bookiRecordController.recordHomeData;

    if (haniData != null && bookiData != null) {
      return 'c';
    } else if (haniData != null && bookiData == null) {
      return 'a';
    } else if (haniData == null && bookiData != null) {
      return 'b';
    } else {
      return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: MainAppBar(
        title: ' ',
        isContent: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/icons/learning_record.png',
                        scale: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '학습기록',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          String status = await checkRecordServices();
                          Get.to(() => RecordClassScreen(type: widget.type, classStatus: status));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color(0xFFD7AFFF),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.asset(
                                        'assets/images/icons/h5_2.png',
                                        scale: 2.5,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: fontMain, fontSize: 24),
                                        children: [
                                          TextSpan(text: '하이파이브 '),
                                          TextSpan(
                                            text: '우리반 언어활동',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    'assets/images/icons/go.png',
                                    scale: 2.5,
                                  ),
                                ),
                              ],
                            ),
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await reportStarService(widget.keyCode);
                          Get.to(() => RecordHomeSchoolScreen(type: widget.type, keyCode: widget.keyCode));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color(0xFFFF7E58),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.asset(
                                        'assets/images/icons/h5_1.png',
                                        scale: 2.5,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: fontMain, fontSize: 24),
                                        children: [
                                          TextSpan(text: '하이파이브 '),
                                          TextSpan(
                                            text: '우리아이 가정활동',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    'assets/images/icons/go.png',
                                    scale: 2.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await kidokBookcaseService(widget.keyCode);
                          final kidokBookcaseController = Get.find<KidokBookcaseDataController>();
                          int lastIndex = kidokBookcaseController.kidokBookcaseDataList.length - 1;
                          await kidokSublistService(
                            kidokBookcaseController.kidokBookcaseDataList[lastIndex].volume,
                            widget.keyCode,
                          );
                          await kidokChartService(
                            kidokBookcaseController.kidokBookcaseDataList[lastIndex].volume,
                            widget.keyCode,
                          );
                          Get.to(() => KidokMainScreen(keyCode: widget.keyCode, type: widget.type, isSibling: false));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color(0xFF9CFF54),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.asset(
                                        'assets/images/icons/kd.png',
                                        scale: 2.5,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: fontMain, fontSize: 24),
                                        children: [
                                          TextSpan(text: '키도키독 '),
                                          TextSpan(
                                            text: '독서클리닉 책장',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    'assets/images/icons/go.png',
                                    scale: 2.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
