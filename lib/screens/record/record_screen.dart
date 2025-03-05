import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/content_star_data.dart';
import 'package:hani_booki/_data/star_data.dart';
import 'package:hani_booki/screens/record/record_widgets/record_list.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:logger/logger.dart';

class RecordScreen extends StatefulWidget {
  final String type;

  const RecordScreen({super.key, required this.type});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final star = Get.find<StarDataController>();

  final contentStar = Get.find<ContentStarDataController>();

  double _getMaxScore() {
    if (contentStar.contentStarDataList.isEmpty) return 20;
    return contentStar.contentStarDataList
        .map((data) => double.parse(data.starCount))
        .reduce((a, b) => a > b ? a : b);
  }

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
          width: MediaQuery.of(context).size.width * 0.85,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: RecordList(
                      type: widget.type,
                    )),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xFFFFF3C8),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF7928),
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
                                          flex: 1,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              '${star.totalStar.value}개 획득',
                                              style: TextStyle(
                                                color: fontWhite,
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.bold,
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
                                child: Container(
                                  decoration:
                                      BoxDecoration(color: Colors.transparent),
                                  child: contentStar.contentStarDataList.length
                                          .isEqual(0)
                                      ? Center(
                                          child: Text(
                                            '학습 기록이 없습니다.',
                                            style: TextStyle(
                                                color: fontSub,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : LayoutBuilder(
                                          builder: (context, constraints) {
                                            return BarChart(
                                              BarChartData(
                                                maxY: _getMaxScore(),
                                                barGroups: _generateBarGroups(
                                                    constraints),
                                                titlesData: FlTitlesData(
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      getTitlesWidget:
                                                          (double value,
                                                              TitleMeta meta) {
                                                        if (value.toInt() <
                                                            contentStar
                                                                .contentStarDataList
                                                                .length) {
                                                          String categoryKey =
                                                              contentStar
                                                                  .contentStarDataList[
                                                                      value
                                                                          .toInt()]
                                                                  .category;
                                                          String categoryName = widget
                                                                      .type ==
                                                                  'hani'
                                                              ? haniCategory[
                                                                      categoryKey] ??
                                                                  ''
                                                              : bookiCategory[
                                                                      categoryKey] ??
                                                                  '';

                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Text(
                                                                categoryName),
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      },
                                                      reservedSize: constraints
                                                              .maxHeight /
                                                          5,
                                                    ),
                                                  ),
                                                  topTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                  rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                  leftTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                ),
                                                gridData: FlGridData(
                                                  drawVerticalLine: false,
                                                  show: true,
                                                  getDrawingHorizontalLine:
                                                      (value) {
                                                    return FlLine(
                                                      color: Colors.grey[400],
                                                      strokeWidth: 1,
                                                      dashArray: [4, 2],
                                                    );
                                                  },
                                                ),
                                                borderData:
                                                    FlBorderData(show: false),
                                                extraLinesData: ExtraLinesData(
                                                  horizontalLines: [
                                                    HorizontalLine(
                                                      y: 0,
                                                      color: fontMain,
                                                      strokeWidth: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
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

  List<BarChartGroupData> _generateBarGroups(constraints) {
    final scores = [];

    for (var data in contentStar.contentStarDataList) {
      scores.add(double.parse(data.starCount));
    }

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    return List.generate(
      scores.length,
      (index) {
        final score = scores[index];

        Color barColor = Color(0xFFFBB50E);
        if (score == maxScore) {
          barColor = Colors.red;
        } else if (score == minScore) {
          barColor = Colors.green;
        }

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: scores[index].toDouble(),
              color: barColor,
              width: constraints.maxWidth * 0.1,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    Get.find<BgmController>().resumeBgm();
    super.dispose();
  }
}
