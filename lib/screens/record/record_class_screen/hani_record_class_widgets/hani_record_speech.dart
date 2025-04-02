import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/record/hani_record_highfive_data.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/utils/radar_chart.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:logger/logger.dart';

class HaniRecordSpeech extends StatefulWidget {
  const HaniRecordSpeech({super.key});

  @override
  State<HaniRecordSpeech> createState() => _HaniRecordSpeechState();
}

class _HaniRecordSpeechState extends State<HaniRecordSpeech> {
  final highFiveData = Get.find<HaniRecordHighfiveDataController>();

  final RxInt selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (highFiveData.recordHighfiveDataList == null || highFiveData.recordHighfiveDataList.isEmpty) {
        return const Center(child: EmptyRecords());
      }

      List<double> rawValues = List.generate(5, (index) {
        try {
          final value = double.parse(highFiveData.recordHighfiveDataList[index].averageScore) / 5.0;
          return value;
        } catch (e) {
          return 0.0;
        }
      });

      List<String> labels = List.generate(5, (index) {
        try {
          final label = removeWord(highFiveData.recordHighfiveDataList[index].subject);
          return label;
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
                  gradientColors: [
                    Color(0xFF9966FF).withOpacity(0.5),
                    Color(0xFF9966FF).withOpacity(0.5),
                  ],
                  onLabelTap: (index) {
                    if (index >= 0 && index < highFiveData.recordHighfiveDataList.length) {
                      selectedIndex.value = index;
                    } else {}
                    return selectedIndex;
                  },
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Obx(() => SpeechCard(
                    highFiveData: highFiveData,
                    selectedIndex: selectedIndex.value,
                  )),
            ),
          ],
        ),
      );
    });
  }
}

class SpeechCard extends StatelessWidget {
  final HaniRecordHighfiveDataController highFiveData;
  final int selectedIndex;

  SpeechCard({super.key, required this.highFiveData, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    if (highFiveData.recordHighfiveDataList == null || highFiveData.recordHighfiveDataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedData = highFiveData.recordHighfiveDataList[selectedIndex];

    List<String> cards = [
      selectedData.contentCard1,
      selectedData.contentCard2,
      selectedData.contentCard3,
      selectedData.contentCard4
    ];
    final nonEmptyCards = cards.where((e) => e.isNotEmpty).toList();

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
                      color: HighFiveTextColor[highFiveData.recordHighfiveDataList[selectedIndex].index]),
                ),
              ),
            ),
            Column(
              children: List.generate(
                nonEmptyCards.length,
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
                          nonEmptyCards[index],
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
                autoWrapText(selectedData.summary, 12),
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
