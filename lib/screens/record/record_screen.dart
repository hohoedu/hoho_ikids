import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_screen.dart';
import 'package:hani_booki/screens/record/record_class_screen/record_class_screen.dart';
import 'package:hani_booki/screens/record/record_home_shool/record_home_school_screen.dart';
import 'package:hani_booki/services/kidok/kidok_bookcase_service.dart';
import 'package:hani_booki/services/kidok/kidok_chart_service.dart';
import 'package:hani_booki/services/kidok/kidok_sublist_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';

class RecordScreen extends StatelessWidget {
  final String type;
  final String keyCode;

  const RecordScreen({super.key, required this.type, required this.keyCode});

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
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
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
                        onTap: () {
                          Get.to(() => RecordClassScreen());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            color: Color(0xFFD7AFFF),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => RecordHomeSchoolScreen(type: type));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            color: Color(0xFFFF7E58),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                    'assets/images/icons/board_type1.png'),
                                Text('하이파이브 우리반 언어활동'),
                                Icon(Icons.navigate_next)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await kidokBookcaseService(keyCode);
                          final kidokBookcaseController =
                              Get.find<KidokBookcaseDataController>();
                          int lastIndex = kidokBookcaseController
                                  .kidokBookcaseDataList.length -
                              1;
                          await kidokSublistService(
                            kidokBookcaseController
                                .kidokBookcaseDataList[lastIndex].volume,
                            keyCode,
                          );
                          await kidokChartService(
                            kidokBookcaseController
                                .kidokBookcaseDataList[lastIndex].volume,
                            keyCode,
                          );
                          Get.to(() => KidokMainScreen(
                              keyCode: keyCode, type: type, isSibling: false));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            color: Color(0xFF9CFF54),
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
