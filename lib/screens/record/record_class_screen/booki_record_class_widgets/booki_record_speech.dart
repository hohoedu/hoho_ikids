import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/record/booki_record_highfive_data.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/screens/record/record_class_screen/hani_record_class_widgets/hani_record_speech.dart';
import 'package:hani_booki/utils/radar_chart.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:logger/logger.dart';

class BookiRecordSpeech extends StatefulWidget {
  const BookiRecordSpeech({super.key});

  @override
  State<BookiRecordSpeech> createState() => _BookiRecordSpeechState();
}

class _BookiRecordSpeechState extends State<BookiRecordSpeech> {
  final highFiveData = Get.find<BookiRecordHighfiveDataController>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (highFiveData.recordHighfiveDataList == null || highFiveData.recordHighfiveDataList.isEmpty) {
          return const Center(child: EmptyRecords());
        }

        List<double> rawValues = List.generate(5, (index) {
          try {
            return double.parse(highFiveData.recordHighfiveDataList[index].averageScore) / 5.0;
          } catch (e) {
            return 0.0; // 잘못된 값은 0.0으로 처리
          }
        });

        List<String> labels = List.generate(5, (index) {
          try {
            return removeWord(highFiveData.recordHighfiveDataList[index].subject);
          } catch (e) {
            return "데이터 없음";
          }
        });

        return Center(
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadarChartWidget(
                    values: rawValues,
                    labels: labels,
                    gradientColors: [ Color(0xFF5FEADA).withOpacity(0.5),
                      Color(0xFF5FEADA).withOpacity(0.5),

                    ],
                    onLabelTap: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: SpeechCard(
                  highFiveData: highFiveData,
                  selectedIndex: selectedIndex,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SpeechCard extends StatelessWidget {
  final BookiRecordHighfiveDataController highFiveData;
  final int selectedIndex;

  const SpeechCard({super.key, required this.highFiveData, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    if (highFiveData.recordHighfiveDataList == null || highFiveData.recordHighfiveDataList.isEmpty) {
      return const Center(child: EmptyRecords());
    }

    final selectedData = highFiveData.recordHighfiveDataList[selectedIndex];

    List<String> cards = [
      selectedData.contentCard1,
      selectedData.contentCard2,
      selectedData.contentCard3,
      selectedData.contentCard4
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey),
          color: Colors.transparent,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  selectedData.subject,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: HighFiveTextColor[highFiveData.recordHighfiveDataList[selectedIndex].index],
                  ),
                ),
              ),
            ),
            Column(
              children: List.generate(
                cards.where((e) => e.isNotEmpty).length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 2.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HighFiveColor[highFiveData.recordHighfiveDataList[selectedIndex].index],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          cards[index],
                          style: TextStyle(color: fontWhite),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                selectedData.summary,
                style: TextStyle(fontSize: 6.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
