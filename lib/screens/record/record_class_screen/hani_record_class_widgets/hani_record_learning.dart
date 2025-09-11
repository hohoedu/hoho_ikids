import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/record/hani_record_learning_data.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class HaniRecordLearning extends StatelessWidget {
  final recordLearningData = Get.put(HaniRecordLearningDataController());

  HaniRecordLearning({super.key});

  Widget _buildLeftItem(String title, int index) {
    List<String> icons = [
      'assets/images/icons/level.png',
      'assets/images/icons/life_topic.png',
      'assets/images/icons/tenacity_topic.png',
    ];
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2CC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icons[index],
                  scale: 2,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 6.sp,
                    fontWeight: FontWeight.bold,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRichText() {
    List<String> newChinese() {
      String text = recordLearningData.recordLearningData!.chinese;
      return text.split('').where((char) => char.trim().isNotEmpty).toList();
    }

    String level = recordLearningData.recordLearningData!.leverString.substring(3, 4);
    String course = recordLearningData.recordLearningData!.leverString.substring(0, 2);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5E4B5), width: 1.0),
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: RichText(
          text: course == '신동'
              ? TextSpan(
                  style: TextStyle(fontSize: 7.sp, color: Colors.black),
                  children: [
                    const TextSpan(text: '신습한자 '),
                    ...newChinese().map(
                      (char) => WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF0F0F0),
                          ),
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: 6.sp,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' 총 ${newChinese().length}자를 배웠어요.'),
                  ],
                )
              : level == '5' || level == '10'
                  ? TextSpan(
                      style: TextStyle(fontSize: 7.sp, color: Colors.black),
                      children: [
                        const TextSpan(text: '복습한자 '),
                        TextSpan(text: '${recordLearningData.recordLearningData!.chinese}을 배웠어요.'),
                      ],
                    )
                  : TextSpan(
                      style: TextStyle(fontSize: 7.sp, color: Colors.black),
                      children: [
                        const TextSpan(text: '신습한자 '),
                        ...newChinese().map(
                          (char) => WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF0F0F0),
                              ),
                              child: Text(
                                char,
                                style: TextStyle(
                                  fontSize: 6.sp,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(text: ' 총 ${newChinese().length}자를 배웠어요.'),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildCircleItem(Color bgColor, List<String> texts) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: constraints.maxHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: texts.asMap().entries.map(
              (entry) {
                int idx = entry.key;
                String text = entry.value;
                return Text(
                  text,
                  style: TextStyle(
                    fontSize: idx == 0 ? 6.sp : 7.sp,
                    fontWeight: FontWeight.bold,
                    color: idx == 0 ? Colors.black : fontWhite,
                    height: idx == 0 ? 1.5 : 1.3,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ).toList(),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 1000 ? true : false;

    return Obx(() {
      if (recordLearningData.recordLearningData == null) {
        return const Center(child: EmptyRecords());
      }

      final leftTitles = [
        recordLearningData.recordLearningData!.leverString,
        recordLearningData.recordLearningData!.lifeTopic,
        recordLearningData.recordLearningData!.tenacityTopic,
      ];
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: leftTitles.asMap().entries.map((e) => _buildLeftItem(e.value, e.key)).toList(),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(flex: 2, child: _buildRichText()),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: isTablet ? 6 : 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleItem(const Color(0xFFF8B82F), [
                          recordLearningData.recordLearningData!.part_1,
                          newLineAfterThird(
                            recordLearningData.recordLearningData!.note_1,
                          )
                        ]),
                        _buildCircleItem(const Color(0xFF57A6FF), [
                          recordLearningData.recordLearningData!.part_2,
                          newLineAfterThird(
                            recordLearningData.recordLearningData!.note_2,
                          ),
                        ]),
                        _buildCircleItem(const Color(0xFF85CF3C), [
                          recordLearningData.recordLearningData!.part_3,
                          newLineAfterThird(
                            recordLearningData.recordLearningData!.note_3,
                          ),
                        ]),
                      ],
                    ),
                  ),
                  Visibility(visible: isTablet, child: Spacer(flex: 1)),
                  Expanded(
                    flex: isTablet ? 6 : 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleItem(const Color(0xFFEA7EC3), [
                          recordLearningData.recordLearningData!.part_4,
                          newLineAfterThird(
                            recordLearningData.recordLearningData!.note_4,
                          ),
                        ]),
                        _buildCircleItem(const Color(0xFFF3825F), [
                          recordLearningData.recordLearningData!.part_5,
                          newLineAfterThird(
                            recordLearningData.recordLearningData!.note_5,
                          ),
                        ]),
                        _buildCircleItem(const Color(0xFF867DF2), [
                          recordLearningData.recordLearningData!.part_6,
                          newLineAfterThird(
                            recordLearningData.recordLearningData!.note_6,
                          ),
                        ]),
                      ],
                    ),
                  ),
                  Visibility(visible: isTablet, child: Spacer(flex: 2)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
