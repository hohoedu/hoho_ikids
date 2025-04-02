import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/record/booki_record_learning_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/utils/text_format.dart';

class BookiRecordLearning extends StatelessWidget {
  final recordLearningData = Get.put(BookiRecordLearningDataController());

  BookiRecordLearning({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildBoxItem(Color bgColor, String text, String note) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold,
                          color: fontMain,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 6.5.sp,
                        fontWeight: FontWeight.bold,
                        color: fontWhite,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Obx(() {
      if (recordLearningData.recordLearningData == null) {
        return const Center(child: EmptyRecords());
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/icons/bookmark.png',
                                scale: 2.5,
                              ),
                              SizedBox(width: 4.0),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(color: fontMain, fontSize: 5.sp, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(text: '표현하는 놀이독서 '),
                                    TextSpan(text: '${recordLearningData.recordLearningData!.leverString}: '),
                                    TextSpan(text: '${recordLearningData.recordLearningData!.subject}'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildBoxItem(
                                const Color(0xFFF8B82F),
                                recordLearningData.recordLearningData!.part_1,
                                recordLearningData.recordLearningData!.note_1,
                                // '나의 경험에 빗대어 공감하기 처럼 텍스트가 길면?'
                              ),
                              buildBoxItem(
                                const Color(0xFF57A6FF),
                                recordLearningData.recordLearningData!.part_2,
                                recordLearningData.recordLearningData!.note_2,
                              ),
                              buildBoxItem(
                                const Color(0xFF85CF3C),
                                recordLearningData.recordLearningData!.part_3,
                                recordLearningData.recordLearningData!.note_3,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildBoxItem(
                                const Color(0xFFEA7EC3),
                                recordLearningData.recordLearningData!.part_4,
                                recordLearningData.recordLearningData!.note_4,
                              ),
                              buildBoxItem(
                                const Color(0xFFF3825F),
                                recordLearningData.recordLearningData!.part_5,
                                recordLearningData.recordLearningData!.note_5,
                              ),
                              buildBoxItem(
                                const Color(0xFF867DF2),
                                recordLearningData.recordLearningData!.part_6,
                                recordLearningData.recordLearningData!.note_6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 오른쪽 영역
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Container(
                  color: Color(0xFFFFF6DA),
                  child: ListView(
                    padding: const EdgeInsets.only(top: 24.0),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icons/tenacity_story.png',
                            scale: screenWidth >= 1000 ? 1.5 : 2.5,
                          ),
                          Text(
                            recordLearningData.recordLearningData!.lifeTopic,
                            style: TextStyle(
                              fontSize: 7.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(
                                0xFF5B4527,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          autoWrapText(
                            recordLearningData.recordLearningData!.topicNote,
                            10,
                          ),
                          style: TextStyle(fontSize: 5.sp, color: fontMain),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
